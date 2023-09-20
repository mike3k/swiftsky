//
//  swiftskyApp_ios.swift
//  swiftsky-ios
//
//  Created by Mike Cohen on 9/19/23.
//
//
import SwiftUI

@ViewBuilder
private var appView: some View {
  if UIDevice.current.userInterfaceIdiom == .pad {
      SidebarView()
  } else {
      Tabs()
  }
}

@main
struct swiftskyApp: App {
  @StateObject private var auth = Auth.shared
  @StateObject private var globalviewmodel = GlobalViewModel.shared
  @StateObject private var pushnotifications = PushNotificatios.shared
  @StateObject private var preferences = PreferencesModel.shared
  init() {
    Client.shared.postInit()
    GlobalViewModel.shared.systemLanguageCode = Locale.preferredLanguageCodes[0]
    GlobalViewModel.shared.systemLanguage = Locale.current.localizedString(forLanguageCode: GlobalViewModel.shared.systemLanguageCode) ?? "en"
  }
  var body: some Scene {
    WindowGroup {
        appView
        .sheet(isPresented: $auth.needAuthorization) {
            LoginView()
        }
      .environmentObject(auth)
      .environmentObject(globalviewmodel)
      .environmentObject(pushnotifications)
      .environmentObject(preferences)
    }
    .commands {
      CommandMenu("Account") {
        if let profile = globalviewmodel.profile {
          Text("@\(profile.handle)")
          Button("Sign out") {
            auth.signout()
          }
        }
      }
    }
    .onChange(of: auth.needAuthorization) {
      if !$0 {
        pushnotifications.resumeRefreshTask()
        Task {
          self.globalviewmodel.profile = try? await actorgetProfile(actor: Client.shared.handle)
        }
      }
      else {
        pushnotifications.cancelRefreshTask()
      }
    }
    #if os(macOS)
    Settings {
      SettingsView()
    }
    #endif
  }
}
