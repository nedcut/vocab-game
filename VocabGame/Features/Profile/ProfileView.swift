import SwiftUI

struct ProfileView: View {
  @Environment(AppStore.self) private var store

  var body: some View {
    @Bindable var store = store

    ScrollView {
      VStack(alignment: .leading, spacing: 18) {
        HStack(spacing: 14) {
          AvatarView(player: store.currentUser, size: 64)
          VStack(alignment: .leading, spacing: 4) {
            Text("Player profile")
              .font(.largeTitle.weight(.bold))
            Text("Local prototype")
              .font(.subheadline)
              .foregroundStyle(AppTheme.quietInk)
          }
        }

        VStack(alignment: .leading, spacing: 14) {
          Button {
          } label: {
            Label("Continue with Apple", systemImage: "apple.logo")
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.borderedProminent)
          .controlSize(.large)

          Text("Apple Sign In, Supabase accounts, and invite links can plug in here once the play loop feels right.")
            .font(.footnote)
            .foregroundStyle(AppTheme.quietInk)
            .fixedSize(horizontal: false, vertical: true)
        }
        .panel()

        VStack(alignment: .leading, spacing: 14) {
          Toggle("Daily reminder", isOn: $store.notificationsEnabled)
          Stepper("Reminder hour: \(store.preferredReminderHour):00", value: $store.preferredReminderHour, in: 7...22)

          HStack(spacing: 10) {
            Image(systemName: store.notificationsEnabled ? "bell.badge.fill" : "bell.slash.fill")
              .foregroundStyle(store.notificationsEnabled ? AppTheme.mint : AppTheme.quietInk)
              .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
              Text(store.reminderStatus.title)
                .font(.subheadline.weight(.semibold))
              Text(store.reminderMessage)
                .font(.caption)
                .foregroundStyle(AppTheme.quietInk)
                .fixedSize(horizontal: false, vertical: true)
            }
          }
        }
        .panel()

        VStack(alignment: .leading, spacing: 8) {
          Text("Next backend pieces")
            .font(.headline)
          Label("Supabase tables for groups, memberships, daily puzzles, and scores", systemImage: "database.fill")
          Label("Spoiler-safe score reads after completion", systemImage: "eye.slash.fill")
          Label("Push notifications for daily drops and friend finishes", systemImage: "bell.badge.fill")
        }
        .font(.subheadline)
        .foregroundStyle(AppTheme.quietInk)
        .panel()
      }
      .padding(20)
    }
    .background(AppTheme.background)
    .navigationTitle("Profile")
  }
}
