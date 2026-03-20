import AppKit
import UniformTypeIdentifiers

extension Notification.Name {
  static let tempFilesChanged = Notification.Name("tempFilesChanged")
}

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

  // MARK: - Temporary Files

  /// Saves a capture item to a temporary directory and returns the file URL.
  @discardableResult
  static func saveAsTemp(_ item: CaptureItem) -> URL? {
    let tempDir = FileManager.default.temporaryDirectory
    let fileURL = tempDir.appendingPathComponent(item.filename)
    guard let data = item.pngData() else { return nil }
    try? data.write(to: fileURL)
    return fileURL
  }

  /// Removes the temporary file associated with a single capture item.
  static func deleteTempFile(for item: CaptureItem) {
    guard let url = item.tempFileURL else { return }
    try? FileManager.default.removeItem(at: url)
  }

  /// Removes all `Capture_*.png` files from the system temporary directory.
  static func clearAllTempFiles() {
    let tempDir = FileManager.default.temporaryDirectory
    guard let files = try? FileManager.default.contentsOfDirectory(
      at: tempDir, includingPropertiesForKeys: nil
    ) else { return }
    for file in files where file.lastPathComponent.hasPrefix("Capture_")
      && file.pathExtension == "png" {
      try? FileManager.default.removeItem(at: file)
    }
  }

  /// Removes SwiftUI drag cache directories that contain our `Capture_*.png` files.
  static func clearDragCache() {
    guard let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first,
      let contents = try? FileManager.default.contentsOfDirectory(at: cachesDir, includingPropertiesForKeys: nil)
    else { return }
    for dir in contents where dir.lastPathComponent.hasPrefix("com.apple.SwiftUI.Drag-") {
      guard let files = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
      else { continue }
      let hasCaptureFile = files.contains { $0.lastPathComponent.hasPrefix("Capture_") && $0.pathExtension == "png" }
      if hasCaptureFile {
        try? FileManager.default.removeItem(at: dir)
      }
    }
  }

  /// Returns the combined count and total byte size of temp files and SwiftUI drag cache files.
  static func tempFilesInfo() -> (count: Int, totalSize: Int64) {
    var count = 0
    var totalSize: Int64 = 0

    // Temp directory
    let tempDir = FileManager.default.temporaryDirectory
    if let files = try? FileManager.default.contentsOfDirectory(
      at: tempDir, includingPropertiesForKeys: [.fileSizeKey])
    {
      for file in files where file.lastPathComponent.hasPrefix("Capture_")
        && file.pathExtension == "png"
      {
        count += 1
        if let attrs = try? FileManager.default.attributesOfItem(atPath: file.path),
          let size = attrs[.size] as? Int64
        { totalSize += size }
      }
    }

    // SwiftUI drag cache
    if let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first,
      let dirs = try? FileManager.default.contentsOfDirectory(at: cachesDir, includingPropertiesForKeys: nil)
    {
      for dir in dirs where dir.lastPathComponent.hasPrefix("com.apple.SwiftUI.Drag-") {
        if let files = try? FileManager.default.contentsOfDirectory(
          at: dir, includingPropertiesForKeys: [.fileSizeKey])
        {
          let hasCaptureFile = files.contains {
            $0.lastPathComponent.hasPrefix("Capture_") && $0.pathExtension == "png"
          }
          guard hasCaptureFile else { continue }
          for file in files {
            count += 1
            if let attrs = try? FileManager.default.attributesOfItem(atPath: file.path),
              let size = attrs[.size] as? Int64
            { totalSize += size }
          }
        }
      }
    }

    return (count, totalSize)
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
