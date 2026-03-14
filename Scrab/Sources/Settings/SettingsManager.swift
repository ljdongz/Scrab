import Foundation
import ServiceManagement
import SwiftUI

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

  var launchAtLogin: Bool {
    get {
      SMAppService.mainApp.status == .enabled
    }
    set {
      do {
        if newValue {
          try SMAppService.mainApp.register()
        } else {
          try SMAppService.mainApp.unregister()
        }
      } catch {
        print("Launch at login error: \(error)")
      }
    }
  }

  private init() {
    savePath = UserDefaults.standard.string(forKey: "savePath") ?? "~/Desktop"
    newestFirst = UserDefaults.standard.object(forKey: "newestFirst") as? Bool ?? true
    captureSoundEnabled = UserDefaults.standard.object(forKey: "captureSoundEnabled") as? Bool ?? true
  }
}
