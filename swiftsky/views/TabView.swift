//
//  TabView.swift
//  swiftsky-ios
//
//  Created by Mike Cohen on 9/19/23.
//
import SwiftUI

struct Tabs: View {
  @EnvironmentObject private var auth: Auth
  @EnvironmentObject private var globalviewmodel: GlobalViewModel
  @EnvironmentObject private var pushnotifications: PushNotificatios
  @EnvironmentObject private var preferences: PreferencesModel
  @State private var selection: Navigation.Sidebar? = nil
  @State private var path: [Navigation] = []
  @State var compose: Bool = false
  @State var replypost: Bool = false
  @State private var post: FeedDefsPostView? = nil
  @State var searchactors = ActorSearchActorsTypeaheadOutput()
  @State var searchpresented = false
  @State var preferencesLoading = false
  @State var preferencesLoadingError: String? = nil
  func load() async {
    preferencesLoadingError = nil
    if !auth.needAuthorization {
      Task {
        self.globalviewmodel.profile = try? await actorgetProfile(actor: Client.shared.handle)
      }
      preferencesLoading = true
      do
      {
        try await preferences.sync()
        try await SavedFeedsModel.shared.updateCache()
      } catch {
        preferencesLoadingError = error.localizedDescription
      }
      preferencesLoading = false
    }
  }
  var body: some View {
      TabView(selection: $selection) {
          if let profile = self.globalviewmodel.profile {
            ProfileView(did: profile.did, profile: profile, path: $path)
              .frame(minWidth: 800)
              .navigationTitle(profile.handle)
          }
          else {
            EmptyView()
          }
        HomeView(path: $path)
          .tabItem {
              Label("Home", systemImage: "house")
          }
        NotificationsView(path: $path)
          .tabItem {
              Label("Notifications", systemImage: "bell.badge")
          }
//        FeedView(model: feed, header: false, path: $path)
        DiscoverFeedsView(path: $path)
          .tabItem{
              Label("Discover", systemImage: "doc.text.magnifyingglass")
          }
        } 
    .onOpenURL(perform: { url in
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
      let did = components?.queryItems?.first { $0.name == "did" }?.value
      guard let did = did else {
          return
      }

      path.append(.profile(did))
    })
    .onChange(of: selection) { _ in
//      path.removeLast(path.count)
    }
    .task {
      selection = .home
      await load()
    }
  }
}
