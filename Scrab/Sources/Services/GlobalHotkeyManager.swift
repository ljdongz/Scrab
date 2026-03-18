import AppKit
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
  #if DEBUG
  static let captureScreen = Self("captureScreen", default: .init(.b, modifiers: [.option, .command]))
  #else
  static let captureScreen = Self("captureScreen", default: .init(.s, modifiers: [.command, .shift]))
  #endif
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
