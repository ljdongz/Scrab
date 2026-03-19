import Foundation
import ServiceManagement
import SwiftUI

enum WidgetPosition: String, CaseIterable {
  case left
  case right
}

@Observable
class SettingsManager {
  static let shared = SettingsManager()

  var savePath: String {
    didSet { UserDefaults.standard.set(savePath, forKey: "savePath") }
  }

  var resolvedSavePath: URL {
    URL(fileURLWithPath: NSString(string: savePath).expandingTildeInPath)
  }

  var newestFirst: Bool {
    didSet { UserDefaults.standard.set(newestFirst, forKey: "newestFirst") }
  }

  var captureSoundEnabled: Bool {
    didSet { UserDefaults.standard.set(captureSoundEnabled, forKey: "captureSoundEnabled") }
  }

  var widgetPosition: WidgetPosition {
    didSet { UserDefaults.standard.set(widgetPosition.rawValue, forKey: "widgetPosition") }
  }

  var launchAtLogin: Bool {
    didSet {
      #if !DEBUG
      do {
        if launchAtLogin {
          try SMAppService.mainApp.register()
        } else {
          try SMAppService.mainApp.unregister()
        }
      } catch {
        print("Launch at login error: \(error)")
      }
      #endif
    }
  }

  private init() {
    savePath = UserDefaults.standard.string(forKey: "savePath") ?? "~/Desktop"
    newestFirst = UserDefaults.standard.object(forKey: "newestFirst") as? Bool ?? true
    captureSoundEnabled = UserDefaults.standard.object(forKey: "captureSoundEnabled") as? Bool ?? true
    widgetPosition = UserDefaults.standard.string(forKey: "widgetPosition")
      .flatMap(WidgetPosition.init(rawValue:)) ?? .right
    launchAtLogin = SMAppService.mainApp.status == .enabled
  }
}
