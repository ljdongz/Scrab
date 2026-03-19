import AppKit

struct CaptureItem: Identifiable {
  let id: UUID = UUID()
  let image: NSImage
  let imageWidth: Int
  let imageHeight: Int
  let createdAt: Date = Date()
  var savedFileURL: URL?
  var tempFileURL: URL?

  var filename: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
    return "Capture_\(formatter.string(from: createdAt)).png"
  }

  var dimensions: String {
    "\(imageWidth) x \(imageHeight)"
  }

  var fileSize: Int {
    imageWidth * imageHeight * 4
  }

  var formattedFileSize: String {
    ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
  }

  var relativeTimeString: String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .abbreviated
    return formatter.localizedString(for: createdAt, relativeTo: Date())
  }

  func pngData() -> Data? {
    guard let tiffData = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiffData) else { return nil }
    return bitmap.representation(using: .png, properties: [:])
  }
}
