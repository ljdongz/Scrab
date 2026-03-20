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
  private weak var settingsWindow: NSWindow?

  override init() {
    updaterController = SPUStandardUpdaterController(
      startingUpdater: true,
      updaterDelegate: nil,
      userDriverDelegate: nil
    )
    super.init()
  }

  func applicationWillTerminate(_ notification: Notification) {
    CaptureFileManager.clearAllTempFiles()
    CaptureFileManager.clearDragCache()
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
        CaptureFileManager.deleteTempFile(for: item)
        self?.captureStore.remove(item)
        CaptureService.refreshClipboardIfNeeded()
      },
      onItemSave: { [weak self] item in
        guard let self else { return }
        if let url = CaptureFileManager.save(item) {
          captureStore.markSaved(item, url: url)
          if let updated = captureStore.items.first(where: { $0.id == item.id }) {
            CaptureService.copyToClipboard(updated)
          }
        }
      },
      onSaveAll: { [weak self] in
        guard let self else { return }
        CaptureFileManager.saveAll(in: captureStore)
        thumbnailController?.handleStoreChange()
      },
      onDeleteAll: { [weak self] in
        self?.captureStore.items.forEach { CaptureFileManager.deleteTempFile(for: $0) }
        self?.captureStore.removeAll()
        CaptureService.refreshClipboardIfNeeded()
      }
    )
  }

  func startCapture() {
    captureService.capture { [weak self] item in
      guard let self, var item else { return }
      if let tempURL = CaptureFileManager.saveAsTemp(item) {
        item.tempFileURL = tempURL
        NotificationCenter.default.post(name: .tempFilesChanged, object: nil)
      }
      captureStore.add(item)
      CaptureService.copyToClipboard(item)
      thumbnailController?.showPanel()
    }
  }

  func openSettings() {
    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    NSApp.activate(ignoringOtherApps: true)
    moveSettingsToMouseScreen()
  }

  func moveSettingsToMouseScreen() {
    // 이미 열린 적 있는 윈도우는 보여주기 전에 미리 이동
    if let window = settingsWindow {
      moveToMouseScreen(window)
    }

    // 처음 열릴 때는 async로 캡처 후 이동
    DispatchQueue.main.async { [weak self] in
      guard let self, let window = NSApp.keyWindow else { return }
      self.settingsWindow = window

      if !window.collectionBehavior.contains(.moveToActiveSpace) {
        window.collectionBehavior.insert(.moveToActiveSpace)
      }

      self.moveToMouseScreen(window)
    }
  }

  private func moveToMouseScreen(_ window: NSWindow) {
    guard let mouseScreen = NSScreen.screens.first(where: {
            NSMouseInRect(NSEvent.mouseLocation, $0.frame, false)
          }),
          window.screen != mouseScreen else { return }

    let visible = mouseScreen.visibleFrame
    let x = visible.midX - window.frame.width / 2
    let y = visible.midY - window.frame.height / 2
    window.setFrameOrigin(NSPoint(x: x, y: y))
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
        CaptureFileManager.deleteTempFile(for: item)
        self?.captureStore.remove(item)
        self?.thumbnailController?.handleStoreChange()
        CaptureService.refreshClipboardIfNeeded()
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
