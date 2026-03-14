import AppKit
import SwiftUI

class PreviewWindowController {
  private var window: NSWindow?
  private var eventMonitor: Any?
  private let item: CaptureItem
  private let onDelete: () -> Void
  private let onClose: () -> Void

  init(item: CaptureItem, onDelete: @escaping () -> Void, onClose: @escaping () -> Void) {
    self.item = item
    self.onDelete = onDelete
    self.onClose = onClose
  }

  func showPreview() {
    guard let screen = NSScreen.main else { return }

    // Calculate window size from image dimensions
    let imageSize = item.image.size
    let maxW = screen.frame.width * 0.8
    let maxH = screen.frame.height * 0.8
    let toolbarH = DesignTokens.previewToolbarHeight
    let maxImageH = maxH - toolbarH
    let scale = min(maxW / imageSize.width, maxImageH / imageSize.height, 1.0)
    let windowWidth = max(imageSize.width * scale, 250)
    let windowHeight = imageSize.height * scale + toolbarH

    // Center on screen
    let x = screen.frame.midX - windowWidth / 2
    let y = screen.frame.midY - windowHeight / 2

    let previewView = PreviewView(
      item: item,
      onCopy: { [weak self] in
        guard let self else { return }
        CaptureService.copyToClipboard(item)
      },
      onSave: { [weak self] in
        guard let self else { return }
        CaptureFileManager.save(item)
      },
      onSaveAs: { [weak self] in
        guard let self else { return }
        CaptureFileManager.saveAs(item)
      },
      onDelete: { [weak self] in
        self?.onDelete()
        self?.dismiss()
      },
      onClose: { [weak self] in self?.dismiss() }
    )

    let hostingView = NSHostingView(
      rootView: previewView
        .ignoresSafeArea()
        .frame(minWidth: 250, minHeight: 250)
    )

    let window = NSWindow(
      contentRect: NSRect(x: x, y: y, width: windowWidth, height: windowHeight),
      styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
      backing: .buffered,
      defer: false
    )

    window.titlebarAppearsTransparent = true
    window.titleVisibility = .hidden
    window.standardWindowButton(.closeButton)?.isHidden = true
    window.standardWindowButton(.miniaturizeButton)?.isHidden = true
    window.standardWindowButton(.zoomButton)?.isHidden = true
    window.backgroundColor = .clear
    window.isOpaque = false

    window.isMovableByWindowBackground = true
    window.collectionBehavior = [.fullScreenAuxiliary]
    window.contentAspectRatio = NSSize(width: windowWidth, height: windowHeight)
    window.contentView = hostingView
    NSApp.activate(ignoringOtherApps: true)
    window.makeKeyAndOrderFront(nil)

    self.window = window

    // Monitor for keyboard shortcuts
    eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
      guard let self else { return event }
      if event.keyCode == 53 { // Escape
        dismiss()
        return nil
      }
      
      return event
    }

    // Animate in
    window.alphaValue = 0
    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.2
      window.animator().alphaValue = 1
    }
  }

  private func dismiss() {
    if let monitor = eventMonitor {
      NSEvent.removeMonitor(monitor)
      eventMonitor = nil
    }

    NSAnimationContext.runAnimationGroup({ context in
      context.duration = 0.15
      self.window?.animator().alphaValue = 0
    }, completionHandler: { [weak self] in
      self?.window?.orderOut(nil)
      self?.window = nil
      self?.onClose()
    })
  }
}
