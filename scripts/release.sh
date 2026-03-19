#!/bin/bash
set -e

# ─── .env 로드 ───
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/.env" ]; then
  source "$SCRIPT_DIR/.env"
else
  echo "오류: scripts/.env 파일이 없습니다."
  exit 1
fi

# ─── 설정 ───
APP_NAME="Scrab"
SCHEME="Scrab"
PROJECT="Scrab.xcodeproj"
HOMEBREW_TAP_REPO="ljdongz/homebrew-tap"
CASK_FILE="$HOMEBREW_TAP_PATH/Casks/scrab.rb"

# ─── 버전 인자 확인 ───
VERSION=$1
if [ -z "$VERSION" ]; then
  echo "사용법: ./scripts/release.sh <version>"
  echo "예시: ./scripts/release.sh 1.0.0"
  exit 1
fi

# ─── App-specific password 확인 ───
if [ -z "$APP_PASSWORD" ]; then
  echo -n "App-specific password: "
  read -s APP_PASSWORD
  echo
fi

PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"
ARCHIVE_PATH="$BUILD_DIR/$APP_NAME.xcarchive"
APP_PATH="$ARCHIVE_PATH/Products/Applications/$APP_NAME.app"
ZIP_PATH="$BUILD_DIR/$APP_NAME-$VERSION.zip"

echo "==> [$APP_NAME v$VERSION] 릴리스 시작"

# ─── 1. 빌드 ───
echo "==> 1/6 빌드 중..."
xcodebuild \
  -project "$PROJECT_DIR/$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  archive \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  -quiet

echo "    빌드 완료"

# ─── 2. 코드 서명 ───
echo "==> 2/6 코드 서명 중..."
codesign --deep --force --options runtime \
  --sign "$SIGN_IDENTITY" \
  "$APP_PATH"
echo "    서명 완료"

# ─── 3. zip 압축 + 공증 ───
echo "==> 3/6 공증 제출 중..."
cd "$(dirname "$APP_PATH")"
zip -r -q "$ZIP_PATH" "$APP_NAME.app"

xcrun notarytool submit "$ZIP_PATH" \
  --apple-id "$APPLE_ID" \
  --team-id "$TEAM_ID" \
  --password "$APP_PASSWORD" \
  --wait

echo "    공증 완료"

# ─── 4. Staple + zip 재생성 ───
echo "==> 4/6 Staple 중..."
xcrun stapler staple "$APP_PATH"
rm "$ZIP_PATH"
zip -r -q "$ZIP_PATH" "$APP_NAME.app"
echo "    Staple 완료"

# ─── 5. GitHub Release ───
echo "==> 5/6 GitHub Release 생성 중..."
cd "$PROJECT_DIR"

# 기존 릴리스가 있으면 삭제
if gh release view "v$VERSION" &>/dev/null; then
  gh release delete "v$VERSION" --yes
  git push origin --delete "v$VERSION" 2>/dev/null || true
fi

gh release create "v$VERSION" "$ZIP_PATH" \
  --title "v$VERSION" \
  --notes "Release v$VERSION (notarized)"

echo "    Release 생성 완료"

# ─── 6. Sparkle appcast.xml 생성 (generate_appcast) ───
echo "==> 6/8 appcast.xml 생성 중..."
SPARKLE_BIN_DIR=$(find ~/Library/Developer/Xcode/DerivedData -path "*/sparkle/Sparkle/bin" -type d 2>/dev/null | head -1)
if [ -z "$SPARKLE_BIN_DIR" ]; then
  echo "    오류: Sparkle bin 디렉토리를 찾을 수 없습니다. Xcode에서 빌드 후 다시 시도하세요."
  exit 1
fi

APPCAST_DIR="$BUILD_DIR/appcast"
mkdir -p "$APPCAST_DIR"
cp "$ZIP_PATH" "$APPCAST_DIR/"

DOWNLOAD_URL_PREFIX="https://github.com/ljdongz/Scrab/releases/download/v$VERSION"
"$SPARKLE_BIN_DIR/generate_appcast" "$APPCAST_DIR" \
  --download-url-prefix "$DOWNLOAD_URL_PREFIX/"

echo "    appcast.xml 생성 완료"

# ─── 7. gh-pages에 appcast.xml push ───
echo "==> 7/8 gh-pages에 appcast.xml 배포 중..."
GH_PAGES_DIR="$BUILD_DIR/gh-pages"
git worktree add "$GH_PAGES_DIR" gh-pages 2>/dev/null || {
  git branch gh-pages 2>/dev/null || true
  git worktree add "$GH_PAGES_DIR" gh-pages
}
cp "$APPCAST_DIR/appcast.xml" "$GH_PAGES_DIR/appcast.xml"
cd "$GH_PAGES_DIR"
git add appcast.xml
git commit -m "Update appcast.xml for v$VERSION" || true
git push origin gh-pages
cd "$PROJECT_DIR"
git worktree remove "$GH_PAGES_DIR" --force

echo "    appcast.xml 배포 완료"

# ─── 8. Homebrew Cask 업데이트 ───
echo "==> 8/8 Homebrew Cask 업데이트 중..."
SHA256=$(shasum -a 256 "$ZIP_PATH" | awk '{print $1}')

sed -i '' "s/version \".*\"/version \"$VERSION\"/" "$CASK_FILE"
sed -i '' "s/sha256 \".*\"/sha256 \"$SHA256\"/" "$CASK_FILE"

cd "$HOMEBREW_TAP_PATH"
git add Casks/
git commit -m "Update $APP_NAME to v$VERSION"
git push origin main

echo "    Cask 업데이트 완료"

# ─── 정리 ───
rm -rf "$BUILD_DIR"
echo ""
echo "==> $APP_NAME v$VERSION 릴리스 완료!"
echo "    설치: brew tap $HOMEBREW_TAP_REPO && brew install --cask $(echo $APP_NAME | tr '[:upper:]' '[:lower:]')"
