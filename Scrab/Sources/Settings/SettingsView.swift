import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
  @Bindable private var settings = SettingsManager.shared
  @State private var tempFileInfo = CaptureFileManager.tempFilesInfo()

  var body: some View {
    Form {
      Section("Save Location") {
        HStack {
          TextField("Save path", text: $settings.savePath)
            .textFieldStyle(.roundedBorder)

          Button("Browse...") {
            let panel = NSOpenPanel()
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
            panel.allowsMultipleSelection = false
            if panel.runModal() == .OK, let url = panel.url {
              settings.savePath = url.path
            }
          }
        }
      }

      Section("Shortcut") {
        KeyboardShortcuts.Recorder("Capture shortcut:", name: .captureScreen)
      }

      Section("Thumbnail Order") {
        Picker("Sort order", selection: $settings.newestFirst) {
          Text("Newest first").tag(true)
          Text("Oldest first").tag(false)
        }
        .pickerStyle(.segmented)
      }

      Section("Thumbnail Position") {
        Picker("Screen side", selection: $settings.widgetPosition) {
          Text("Left").tag(WidgetPosition.left)
          Text("Right").tag(WidgetPosition.right)
        }
        .pickerStyle(.segmented)
      }

      Section("Capture") {
        Toggle("Capture sound", isOn: $settings.captureSoundEnabled)
      }

      Section("Temporary Files") {
        HStack {
          Text(
            "\(tempFileInfo.count) file(s), \(ByteCountFormatter.string(fromByteCount: tempFileInfo.totalSize, countStyle: .file))"
          )
          Spacer()
          Button("Clear") {
            CaptureFileManager.clearAllTempFiles()
            CaptureFileManager.clearDragCache()
            CaptureService.refreshClipboardIfNeeded()
            tempFileInfo = CaptureFileManager.tempFilesInfo()
          }
        }
      }

      #if !DEBUG
      Section("System") {
        Toggle("Launch at login", isOn: $settings.launchAtLogin)
      }
      #endif
    }
    .formStyle(.grouped)
    .frame(width: 450, height: 450)
    .onAppear { tempFileInfo = CaptureFileManager.tempFilesInfo() }
    .onReceive(NotificationCenter.default.publisher(for: .tempFilesChanged)) { _ in
      tempFileInfo = CaptureFileManager.tempFilesInfo()
    }
  }
}
