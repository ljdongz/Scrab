//
//  ScrabApp.swift
//  Scrab
//
//  Created by 이정동 on 2/22/26.
//

import Sparkle
import SwiftUI

@main
struct ScrabApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  @Environment(\.openSettings) private var openSettings

  @ViewBuilder
  private var menuContent: some View {
    Button("Capture") {
      appDelegate.startCapture()
    }
    .keyboardShortcut("s", modifiers: [.command, .shift])
    Divider()
    Button("Check for Updates...") {
      appDelegate.updaterController.checkForUpdates(nil)
    }
    Button("Settings...") {
      appDelegate.moveSettingsToMouseScreen()
      openSettings()
      NSApp.activate(ignoringOtherApps: true)
    }
    .keyboardShortcut(",", modifiers: .command)
    Divider()
    Button("Quit") {
      NSApplication.shared.terminate(nil)
    }
    .keyboardShortcut("q", modifiers: .command)
  }

  var body: some Scene {
    #if DEBUG
    MenuBarExtra("[Debug] Scrab", systemImage: "scissors") {
      menuContent
    }
    #else
    MenuBarExtra("Scrab", image: "menuBarIcon") {
      menuContent
    }
    #endif

    Settings {
      SettingsView(updater: appDelegate.updaterController.updater)
    }
  }
}
