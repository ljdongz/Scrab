import AppKit
import SwiftUI

private class VerticalOnlyPanel: NSPanel {
  static let edgePadding: CGFloat = 10
  private var dragStartY: CGFloat?
  private var frameStartY: CGFloat?

  override var canBecomeKey: Bool { false }

  override func mouseDown(with event: NSEvent) {
    dragStartY = NSEvent.mouseLocation.y
    frameStartY = frame.origin.y
  }

  override func mouseDragged(with event: NSEvent) {
    guard let startMouseY = dragStartY, let startFrameY = frameStartY,
        let screen = screen ?? NSScreen.main else { return }
    let visible = screen.visibleFrame
    let minY = visible.minY + Self.edgePadding
    let maxY = visible.maxY - frame.height - Self.edgePadding

    let deltaY = NSEvent.mouseLocation.y - startMouseY
    let newY = min(max(startFrameY + deltaY, minY), maxY)
    setFrameOrigin(NSPoint(x: frame.origin.x, y: newY))
  }

  override func mouseUp(with event: NSEvent) {
    dragStartY = nil
    frameStartY = nil
    snapToNearestPosition()
  }

  private func snapToNearestPosition() {
    guard let screen = screen ?? NSScreen.main else { return }
    let visible = screen.visibleFrame
    let minY = visible.minY + Self.edgePadding
    let maxY = visible.maxY - frame.height - Self.edgePadding
    let range = maxY - minY

    let snapRatios: [CGFloat] = [0, 0.25, 0.5, 0.75, 1.0]
    let currentRatio = range > 0 ? (frame.origin.y - minY) / range : 0

    let nearestRatio = snapRatios.min(by: { abs($0 - currentRatio) < abs($1 - currentRatio) }) ?? 0
    let targetY = minY + range * nearestRatio
    let targetFrame = NSRect(x: frame.origin.x, y: targetY, width: frame.width, height: frame.height)
    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.2
      context.timingFunction = CAMediaTimingFunction(name: .easeOut)
      context.allowsImplicitAnimation = true
      self.animator().setFrame(targetFrame, display: true)
    }
  }
}

class ThumbnailPanelController {
  private var panel: VerticalOnlyPanel?
  private let store: CaptureStore
  private let onItemClick: (CaptureItem) -> Void
  private let onItemClose: (CaptureItem) -> Void
  private let onItemSave: (CaptureItem) -> Void
  private let onSaveAll: () -> Void
  private let onDeleteAll: () -> Void
  private static let panelWidth: CGFloat = 150
  private static let panelHeight: CGFloat = 300
  private static let savedYKey = "thumbnailPanelY"
  private var moveObserver: Any?
  private var contentSetUp = false

  init(
    store: CaptureStore,
    onItemClick: @escaping (CaptureItem) -> Void,
    onItemClose: @escaping (CaptureItem) -> Void,
    onItemSave: @escaping (CaptureItem) -> Void,
    onSaveAll: @escaping () -> Void,
    onDeleteAll: @escaping () -> Void
  ) {
    self.store = store
    self.onItemClick = onItemClick
    self.onItemClose = onItemClose
    self.onItemSave = onItemSave
    self.onSaveAll = onSaveAll
    self.onDeleteAll = onDeleteAll
  }

  deinit {
    if let observer = moveObserver {
      NotificationCenter.default.removeObserver(observer)
    }
  }

  func showPanel() {
    let isNew = panel == nil
    if isNew {
      createPanel()
    }
    setupContentIfNeeded()
    positionPanel()
    panel?.alphaValue = 1
    panel?.orderFront(nil)
  }

  func hidePanel() {
    NSAnimationContext.runAnimationGroup({ context in
      context.duration = DesignTokens.thumbnailDisappearDuration
      context.timingFunction = CAMediaTimingFunction(name: .easeIn)
      self.panel?.animator().alphaValue = 0
    }, completionHandler: { [weak self] in
      self?.panel?.orderOut(nil)
    })
  }

  private func createPanel() {
    let panel = VerticalOnlyPanel(
      contentRect: NSRect(x: 0, y: 0, width: Self.panelWidth, height: Self.panelHeight),
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered,
      defer: false
    )
    panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.mainMenuWindow)) + 1)
    panel.isMovableByWindowBackground = false
    panel.becomesKeyOnlyIfNeeded = true
    panel.backgroundColor = .clear
    panel.isOpaque = false
    panel.hasShadow = false
    panel.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary, .stationary, .ignoresCycle]
    self.panel = panel

    moveObserver = NotificationCenter.default.addObserver(
      forName: NSWindow.didMoveNotification,
      object: panel,
      queue: .main
    ) { [weak self] _ in
      guard let panel = self?.panel else { return }
      UserDefaults.standard.set(Double(panel.frame.origin.y), forKey: Self.savedYKey)
    }
  }

  private func setupContentIfNeeded() {
    guard !contentSetUp else { return }
    contentSetUp = true

    let widgetView = ThumbnailWidgetView(
      store: store,
      onItemClick: { [weak self] item in
        self?.onItemClick(item)
      },
      onItemClose: { [weak self] item in
        self?.onItemClose(item)
        self?.handleStoreChange()
      },
      onItemSave: { [weak self] item in
        self?.onItemSave(item)
      },
      onSaveAll: { [weak self] in
        self?.onSaveAll()
      },
      onDeleteAll: { [weak self] in
        self?.onDeleteAll()
        self?.handleStoreChange()
      }
    )

    let hostingView = NSHostingView(rootView: widgetView)
    let contentSize = NSSize(width: Self.panelWidth, height: Self.panelHeight)
    hostingView.frame.size = contentSize
    panel?.contentView = hostingView
    panel?.setContentSize(contentSize)
  }

  private func positionPanel() {
    guard let panel = panel,
          let screen = NSScreen.screens.first(where: {
            NSMouseInRect(NSEvent.mouseLocation, $0.frame, false)
          }) ?? NSScreen.main else { return }
    let padding = VerticalOnlyPanel.edgePadding
    let visible = screen.visibleFrame
    let x: CGFloat
    switch SettingsManager.shared.widgetPosition {
    case .left:
      x = visible.minX + padding
    case .right:
      x = visible.maxX - Self.panelWidth - padding
    }
    let minY = visible.minY + padding
    let maxY = visible.maxY - Self.panelHeight - padding

    let y: CGFloat
    if UserDefaults.standard.object(forKey: Self.savedYKey) != nil {
      let savedY = CGFloat(UserDefaults.standard.double(forKey: Self.savedYKey))
      y = min(max(savedY, minY), maxY)
    } else {
      y = minY
    }

    panel.setFrame(NSRect(x: x, y: y, width: Self.panelWidth, height: Self.panelHeight), display: true)
  }

  func handleStoreChange() {
    if store.isEmpty {
      panel?.alphaValue = 0
      panel?.orderOut(nil)
    }
  }
}
