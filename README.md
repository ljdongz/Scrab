<img width="100" height="100" alt="scrab" src="https://github.com/user-attachments/assets/ab6d7c67-248b-4cfa-97cc-37a273b39bdc" />

# Scrab

Lightweight macOS menu bar app for fast screen capture. Capture any area of your screen with a single shortcut, manage captures in a floating thumbnail widget, and drag-and-drop or save them wherever you need.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Install](#install)
- [Update](#update)
- [Usage](#usage)
- [Settings](#settings)
- [License](#license)

## Features

- **Instant Capture** — Global hotkey triggers native macOS screen selection
- **Floating Thumbnail Widget** — Captured images appear in a compact sidebar with numbered badges
- **Preview Window** — Click any thumbnail to open a full-size viewer with copy/save/delete actions
- **Drag & Drop** — Drag thumbnails directly into other apps (Slack, Finder, etc.)
- **Clipboard Integration** — Every capture is automatically copied to the clipboard
- **Batch Actions** — Save all or delete all captures at once

## Requirements

- macOS 14.0 (Sonoma) or later

## Install

### Homebrew (Recommended)

```bash
brew install --cask ljdongz/tap/scrab
```

### GitHub Releases

Download the latest `.zip` from [Releases](https://github.com/ljdongz/Scrab/releases) and move `Scrab.app` to `/Applications`.

## Update

### Homebrew

```bash
brew update && brew upgrade scrab
```

### In-App

Scrab checks for updates automatically via Sparkle. You can also trigger a manual check from the menu bar icon > **Check for Updates**.

## Usage

### Capture

Press `⌘ Shift S` to start a screen capture. Drag to select any area — the captured image is automatically copied to the clipboard and appears in the floating thumbnail widget.

- **Paste as image** — `⌘ V` in Slack, Notes, or any image-accepting app to paste the capture
- **Paste as file path** — `⌘ V` in Terminal to paste the temporary file path

The capture shortcut can be customized in Settings.

### Thumbnail Widget

Captured images are listed in a floating sidebar with numbered badges.

- **Click** a thumbnail to open the preview window
- **Hover** to reveal save and delete buttons
- **Drag & Drop** a thumbnail into other apps (Finder, Slack, etc.)
- Use the bottom toolbar to **Save All** or **Delete All** at once

### Preview Window

Click any thumbnail to open a full-size viewer.

- **Copy** — copy the image to the clipboard
- **Save** — save to the configured directory
- **Delete** — remove the capture

### Saving

Click the save button on a thumbnail or in the preview window. The image is saved as PNG to your configured save location (default: `~/Desktop`). After saving, `⌘ V` in Terminal will paste the saved file path instead of the temporary path.

### Temporary File Cleanup

Captured images and drag cache files accumulate over time. Open **Settings > Temporary Files** to see the current file count and size, then click **Clear** to remove them.

## Settings

| Option | Description | Default |
|--------|-------------|---------|
| Save Location | Directory for saved captures | `~/Desktop` |
| Capture Shortcut | Global hotkey for screen capture | `⌘ Shift S` |
| Thumbnail Order | Newest first or oldest first | Newest first |
| Capture Sound | Play sound on capture | On |
| Launch at Login | Start Scrab on login | Off |

## License

MIT
