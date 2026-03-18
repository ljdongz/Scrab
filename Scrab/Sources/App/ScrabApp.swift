//
//  ScrabApp.swift
//  Scrab
//
//  Created by 이정동 on 2/22/26.
//

import SwiftUI

@main
struct ScrabApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  @Environment(\.openSettings) private var openSettings

  @ViewBuilder
  private var menuContent: some View {
    Button("캡처") {
      appDelegate.startCapture()
    }
    .keyboardShortcut("s", modifiers: [.command, .shift])
    Divider()
    Button("Scrab에 관하여") {
      NSApp.activate(ignoringOtherApps: true)
      NSApp.orderFrontStandardAboutPanel()
    }
    Button("설정...") {
      openSettings()
      NSApp.activate(ignoringOtherApps: true)
    }
    .keyboardShortcut(",", modifiers: .command)
    Divider()
    Button("종료") {
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
      SettingsView()
    }
  }
}
