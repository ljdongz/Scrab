import AppKit
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
  static let captureScreen = Self("captureScreen", default: .init(.s, modifiers: [.command, .shift]))
}

final class GlobalHotkeyManager {
  var onCaptureTrigger: (() -> Void)?

  init() {
    KeyboardShortcuts.reset(.captureScreen)
    KeyboardShortcuts.onKeyUp(for: .captureScreen) { [weak self] in
      
      self?.onCaptureTrigger?()
    }
  }

  deinit {
    KeyboardShortcuts.removeHandler(for: .captureScreen)
  }
}
