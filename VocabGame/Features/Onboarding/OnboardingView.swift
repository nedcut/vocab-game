import SwiftUI

struct OnboardingView: View {
  @Environment(AppStore.self) private var store

  @State private var mode: OnboardingGroupMode = .pick
  @State private var groupName = ""
  @State private var inviteCode = ""
  @State private var enableReminders = true

  var body: some View {
    @Bindable var store = store

    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 18) {
          VStack(alignment: .leading, spacing: 8) {
            Text("Set up today")
              .font(.largeTitle.weight(.bold))
            Text("Choose who you are playing with, then jump into the daily set.")
              .font(.subheadline)
              .foregroundStyle(AppTheme.quietInk)
              .fixedSize(horizontal: false, vertical: true)
          }

          VStack(alignment: .leading, spacing: 14) {
            Text("Group")
              .font(.headline)

            Picker("Group setup", selection: $mode) {
              ForEach(OnboardingGroupMode.allCases) { mode in
                Text(mode.title).tag(mode)
              }
            }
            .pickerStyle(.segmented)

            switch mode {
            case .pick:
              Picker("Selected group", selection: $store.selectedGroupID) {
                ForEach(store.groups) { group in
                  Text(group.name).tag(group.id)
                }
              }
              .pickerStyle(.menu)

              SelectedGroupSummary(group: store.selectedGroup)
            case .create:
              TextField("Family, book club, Sunday crew", text: $groupName)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.words)
              Text("This creates a local group for now. Backend invites can take over later.")
                .font(.footnote)
                .foregroundStyle(AppTheme.quietInk)
            case .join:
              TextField("FAM-482", text: $inviteCode)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
              Text("Known demo codes select that group. New codes create a local placeholder group.")
                .font(.footnote)
                .foregroundStyle(AppTheme.quietInk)
            }
          }
          .panel()

          VStack(alignment: .leading, spacing: 14) {
            Toggle(isOn: $enableReminders) {
              Label("Daily reminder", systemImage: "bell.badge.fill")
                .font(.headline)
            }

            Text("You can change reminder settings anytime from Profile.")
              .font(.footnote)
              .foregroundStyle(AppTheme.quietInk)
          }
          .panel()

          VStack(alignment: .leading, spacing: 10) {
            Label("\(store.today.games.count) games today", systemImage: "list.number")
            Label("Scores stay hidden until you finish", systemImage: "eye.slash.fill")
            Label("Daily and weekly leaderboards are ready", systemImage: "chart.bar.fill")
          }
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(AppTheme.quietInk)
          .panel()
        }
        .padding(20)
      }
      .background(AppTheme.background)
      .navigationTitle("Welcome")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Start") {
            finish()
          }
          .font(.body.weight(.semibold))
        }
      }
    }
    .interactiveDismissDisabled()
  }

  private func finish() {
    switch mode {
    case .pick:
      break
    case .create:
      store.createLocalGroup(named: groupName)
    case .join:
      store.joinGroup(inviteCode: inviteCode)
    }
    store.completeOnboarding(enableReminders: enableReminders)
  }
}

private enum OnboardingGroupMode: String, CaseIterable, Identifiable {
  case pick
  case create
  case join

  var id: String { rawValue }

  var title: String {
    switch self {
    case .pick: "Pick"
    case .create: "Create"
    case .join: "Join"
    }
  }
}

private struct SelectedGroupSummary: View {
  let group: FriendGroup

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Text(group.name)
          .font(.subheadline.weight(.bold))
        Spacer()
        Text(group.inviteCode)
          .font(.caption.monospaced().weight(.bold))
          .foregroundStyle(AppTheme.blue)
      }

      HStack(spacing: 8) {
        ForEach(group.members.prefix(4)) { member in
          AvatarView(player: member, size: 32)
        }
        Text("\(group.members.count) players")
          .font(.caption.weight(.semibold))
          .foregroundStyle(AppTheme.quietInk)
      }
    }
  }
}
