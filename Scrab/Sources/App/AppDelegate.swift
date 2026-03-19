import AppKit
import Sparkle
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
  let updaterController: SPUStandardUpdaterController

  private var hotkeyManager: GlobalHotkeyManager?
  let captureStore = CaptureStore()
  private let captureService = CaptureService()
  private var thumbnailController: ThumbnailPanelController?
  private var previewControllers: [PreviewWindowController] = []

  override init() {
    updaterController = SPUStandardUpdaterController(
      startingUpdater: true,
      updaterDelegate: nil,
      userDriverDelegate: nil
    )
    super.init()
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    hotkeyManager = GlobalHotkeyManager()
    hotkeyManager?.onCaptureTrigger = { [weak self] in
      self?.startCapture()
    }

    thumbnailController = ThumbnailPanelController(
      store: captureStore,
      onItemClick: { [weak self] item in
        self?.openPreview(for: item)
      },
      onItemClose: { [weak self] item in
        self?.captureStore.remove(item)
      },
      onItemSave: { [weak self] item in
        guard let self else { return }
        if let url = CaptureFileManager.save(item) {
          captureStore.markSaved(item, url: url)
        }
      },
      onSaveAll: { [weak self] in
        guard let self else { return }
        CaptureFileManager.saveAll(in: captureStore)
        thumbnailController?.handleStoreChange()
      },
      onDeleteAll: { [weak self] in
        self?.captureStore.removeAll()
      }
    )
  }

  func startCapture() {
    captureService.capture { [weak self] item in
      guard let self, let item else { return }
      captureStore.add(item)
      thumbnailController?.showPanel()
    }
  }

  func openSettings() {
    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  private func openPreview(for item: CaptureItem) {
    if let existing = previewControllers.first(where: { $0.item.id == item.id }) {
      existing.bringToFront()
      return
    }

    thumbnailController?.handleStoreChange()
    var controller: PreviewWindowController?
    controller = PreviewWindowController(
      item: item,
      onDelete: { [weak self] in
        self?.captureStore.remove(item)
        self?.thumbnailController?.handleStoreChange()
      },
      onClose: { [weak self] in
        if let ctrl = controller {
          self?.previewControllers.removeAll { $0 === ctrl }
        }
      }
    )
    if let ctrl = controller {
      previewControllers.append(ctrl)
      ctrl.showPreview()
    }
  }
}
