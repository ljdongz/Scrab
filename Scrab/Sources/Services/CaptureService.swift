import AppKit

/// Manages screen capture via macOS native `screencapture` CLI
/// and clipboard operations for captured images.
final class CaptureService {

  private var process: Process?

  var isCapturing: Bool { process != nil }

  // MARK: - Capture

  /// Launches an interactive screen capture. The captured image is sent directly
  /// to the clipboard via `-c`. Calls `completion` on the main thread
  /// with the resulting `CaptureItem`, or `nil` if the user cancelled.
  func capture(completion: @escaping (CaptureItem?) -> Void) {
    guard process == nil else { return }

    let changeCount = NSPasteboard.general.changeCount

    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
    proc.arguments = ["-i", "-c", "-x"]

    proc.terminationHandler = { [weak self] finished in
      DispatchQueue.main.async {
        self?.process = nil

        guard finished.terminationStatus == 0,
              NSPasteboard.general.changeCount != changeCount,
              let image = NSImage(pasteboard: .general) else {
          completion(nil)
          return
        }

        let width = Int(image.representations.first?.pixelsWide ?? Int(image.size.width))
        let height = Int(image.representations.first?.pixelsHigh ?? Int(image.size.height))

        let item = CaptureItem(image: image, imageWidth: width, imageHeight: height)
        if SettingsManager.shared.captureSoundEnabled {
          NSSound(contentsOfFile: "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/Screen Capture.aif", byReference: true)?.play()
        }
        completion(item)
      }
    }

    process = proc
    try? proc.run()
  }

  // MARK: - Clipboard

  /// Copies the given capture item to the system clipboard as both NSImage and PNG data.
  static func copyToClipboard(_ item: CaptureItem) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.writeObjects([item.image])
    if let pngData = item.pngData() {
      pasteboard.setData(pngData, forType: .png)
    }
  }
}
