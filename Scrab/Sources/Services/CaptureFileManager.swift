import AppKit
import UniformTypeIdentifiers

/// Handles saving captured images to disk.
enum CaptureFileManager {

  /// Saves a single capture item to the user's configured save path.
  /// Returns the file URL on success.
  @discardableResult
  static func save(_ item: CaptureItem) -> URL? {
    let savePath = SettingsManager.shared.resolvedSavePath
    let fileURL = savePath.appendingPathComponent(item.filename)
    guard let data = item.pngData() else { return nil }
    try? data.write(to: fileURL)
    return fileURL
  }

  /// Saves all items in the store to the user's configured save path.
  static func saveAll(in store: CaptureStore) {
    for item in store.items {
      if let url = save(item) {
        store.markSaved(item, url: url)
      }
    }
  }

  /// Presents a Save As dialog for the given item.
  static func saveAs(_ item: CaptureItem) {
    guard let data = item.pngData() else { return }
    let panel = NSSavePanel()
    panel.allowedContentTypes = [.png]
    panel.nameFieldStringValue = item.filename
    panel.canCreateDirectories = true
    panel.begin { response in
      if response == .OK, let url = panel.url {
        try? data.write(to: url)
      }
    }
  }
}
