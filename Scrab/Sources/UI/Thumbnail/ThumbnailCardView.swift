import SwiftUI
import UniformTypeIdentifiers

struct ThumbnailCardView: View {
  let item: CaptureItem
  var width: CGFloat = DesignTokens.thumbnailWidgetWidth
  var height: CGFloat = DesignTokens.thumbnailWidgetHeight
  var badgeCount: Int = 0
  var onClose: (() -> Void)?
  var onClick: (() -> Void)?
  var onSave: (() -> Void)?
  var onDragComplete: (() -> Void)?

  @State private var isHovered = false

  var body: some View {
    ZStack(alignment: .trailing) {
      // Image fill
      Image(nsImage: item.image)
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: width, height: height)
        .clipped()
        .blur(radius: isHovered ? 3 : 0)
        .overlay(isHovered ? Color.black.opacity(0.3) : Color.clear)

      // Hover buttons (right side)
      if isHovered {
        VStack(spacing: 12) {
          Button(action: { onSave?() }) {
            Image(.download)
              .resizable()
              .frame(width: 12, height: 12)
              .foregroundStyle(.white)
          }
          .buttonStyle(.plain)
          
          Button(action: { onClose?() }) {
            Image(.delete)
              .resizable()
              .frame(width: 12, height: 12)
              .foregroundStyle(.white)
          }
          .buttonStyle(.plain)
        }
        .padding(.trailing, 8)
        .transition(.opacity)
      }
    }
    .frame(width: width, height: height)
    .background(DesignTokens.bgSurface)
    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.radiusMd))
    .overlay(
      RoundedRectangle(cornerRadius: DesignTokens.radiusMd)
        .stroke(
          item.savedFileURL != nil ? Color.green : DesignTokens.borderSubtle,
          lineWidth: 1
        )
    )
    .overlay(alignment: .topLeading) {
      Text("\(badgeCount)")
        .font(.system(size: 9, weight: .semibold))
        .foregroundStyle(.white)
        .frame(width: 18, height: 18)
        .background(DesignTokens.accent)
        .clipShape(Capsule())
        .offset(x: -6, y: -6)
    }
    .zIndex(1)
    .shadow(
      color: DesignTokens.thumbnailShadow.color,
      radius: DesignTokens.thumbnailShadow.blur / 2,
      y: DesignTokens.thumbnailShadow.y
    )
    .contentShape(Rectangle())
    .onHover { hovering in
      withAnimation(.easeInOut(duration: 0.15)) {
        isHovered = hovering
      }
    }
    .onTapGesture { onClick?() }
    .onDrag {
      let provider = NSItemProvider()
      let dragComplete = onDragComplete

      if let fileURL = item.savedFileURL {
        provider.registerDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier, visibility: .all) { completion in
          completion(fileURL.dataRepresentation, nil)
          DispatchQueue.main.async { dragComplete?() }
          return nil
        }
      }

      if let data = item.pngData() {
        provider.registerDataRepresentation(forTypeIdentifier: UTType.png.identifier, visibility: .all) { completion in
          completion(data, nil)
          if item.savedFileURL == nil {
            DispatchQueue.main.async { dragComplete?() }
          }
          return nil
        }
      }

      provider.suggestedName = item.filename
      return provider
    } preview: {
      Image(nsImage: item.image)
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.radiusMd))
    }
  }
}
