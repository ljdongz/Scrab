# Scrab

Lightweight macOS menu bar app for fast screen capture. Capture any area of your screen with a single shortcut, manage captures in a floating thumbnail widget, and drag-and-drop or save them wherever you need.

## Features

- **Instant Capture** — Global hotkey triggers native macOS screen selection
- **Floating Thumbnail Widget** — Captured images appear in a compact sidebar with numbered badges
- **Preview Window** — Click any thumbnail to open a full-size viewer with copy/save/delete actions
- **Drag & Drop** — Drag thumbnails directly into other apps (Slack, Finder, etc.)
- **Clipboard Integration** — Every capture is automatically copied to the clipboard
- **Batch Actions** — Save all or delete all captures at once
- **Auto Update** — Built-in Sparkle update support

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

## Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Capture Screen | `⌘ Shift S` |
| Settings | `⌘ ,` |
| Quit | `⌘ Q` |

The capture shortcut can be customized in Settings.

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
