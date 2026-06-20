import SwiftUI

struct AppView: View {
  @Environment(AppStore.self) private var store
  @State private var selectedTab: AppTab = .today

  var body: some View {
    TabView(selection: $selectedTab) {
      NavigationStack {
        TodayView()
      }
      .tabItem { Label("Today", systemImage: "sun.max.fill") }
      .tag(AppTab.today)

      NavigationStack {
        GroupsView()
      }
      .tabItem { Label("Groups", systemImage: "person.3.fill") }
      .tag(AppTab.groups)

      NavigationStack {
        LeaderboardsView()
      }
      .tabItem { Label("Leaders", systemImage: "chart.bar.fill") }
      .tag(AppTab.leaderboards)

      NavigationStack {
        ProfileView()
      }
      .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
      .tag(AppTab.profile)
    }
    .task {
      await store.prepareForLaunch()
    }
  }
}

private enum AppTab: Hashable {
  case today
  case groups
  case leaderboards
  case profile
}
