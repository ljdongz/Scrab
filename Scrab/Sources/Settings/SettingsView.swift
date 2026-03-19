import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
  @Bindable private var settings = SettingsManager.shared

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

      Section("Capture") {
        Toggle("Capture sound", isOn: $settings.captureSoundEnabled)
      }

      #if !DEBUG
      Section("System") {
        Toggle("Launch at login", isOn: $settings.launchAtLogin)
      }
      #endif
    }
    .formStyle(.grouped)
    .frame(width: 450, height: 450)
  }
}
