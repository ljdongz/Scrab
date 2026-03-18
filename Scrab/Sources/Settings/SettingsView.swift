import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
  @Bindable private var settings = SettingsManager.shared

  var body: some View {
    Form {
      Section("저장 위치") {
        HStack {
          TextField("저장 경로", text: $settings.savePath)
            .textFieldStyle(.roundedBorder)

          Button("찾아보기...") {
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

      Section("단축키") {
        KeyboardShortcuts.Recorder("캡처 단축키:", name: .captureScreen)
      }

      Section("썸네일 정렬") {
        Picker("정렬 순서", selection: $settings.newestFirst) {
          Text("최신순").tag(true)
          Text("오래된순").tag(false)
        }
        .pickerStyle(.segmented)
      }

      Section("캡처") {
        Toggle("캡처 효과음", isOn: $settings.captureSoundEnabled)
      }

      #if !DEBUG
      Section("시스템") {
        Toggle("로그인 시 자동 실행", isOn: $settings.launchAtLogin)
      }
      #endif
    }
    .formStyle(.grouped)
    .frame(width: 450, height: 450)
  }
}
