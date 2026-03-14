import Foundation

@Observable
class CaptureStore {
  var items: [CaptureItem] = []

  var count: Int { items.count }
  var isEmpty: Bool { items.isEmpty }
  var latestItem: CaptureItem? { items.last }

  func add(_ item: CaptureItem) {
    items.append(item)
  }

  func remove(_ item: CaptureItem) {
    items.removeAll { $0.id == item.id }
  }

  func remove(at index: Int) {
    guard items.indices.contains(index) else { return }
    items.remove(at: index)
  }

  func removeAll() {
    items.removeAll()
  }

  func markSaved(_ item: CaptureItem, url: URL) {
    if let index = items.firstIndex(where: { $0.id == item.id }) {
      items[index].savedFileURL = url
    }
  }
}
