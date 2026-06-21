import AuthenticationServices
import SwiftUI

struct ProfileView: View {
  @Environment(AppStore.self) private var store
  @State private var authErrorMessage: String?

  var body: some View {
    @Bindable var store = store

    ScrollView {
      VStack(alignment: .leading, spacing: 18) {
        HStack(spacing: 14) {
          AvatarView(player: store.currentUser, size: 64)
          VStack(alignment: .leading, spacing: 4) {
            Text(store.account?.displayName ?? "Player profile")
              .font(.largeTitle.weight(.bold))
            Text(store.account?.provider.title ?? "Local prototype")
              .font(.subheadline)
              .foregroundStyle(AppTheme.quietInk)
          }
        }

        accountPanel

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

  @ViewBuilder
  private var accountPanel: some View {
    if let account = store.account {
      signedInPanel(account: account)
    } else {
      signedOutPanel
    }
  }

  private func signedInPanel(account: UserAccount) -> some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack(spacing: 12) {
        Image(systemName: account.provider == .apple ? "apple.logo" : "person.crop.circle.badge.checkmark")
          .font(.title2.weight(.semibold))
          .foregroundStyle(AppTheme.ink)
          .frame(width: 34, height: 34)
          .background(AppTheme.background, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

        VStack(alignment: .leading, spacing: 2) {
          Text(account.displayName)
            .font(.headline)
          Text(account.email ?? "\(account.provider.title) account")
            .font(.subheadline)
            .foregroundStyle(AppTheme.quietInk)
        }

        Spacer()

        Image(systemName: "checkmark.seal.fill")
          .foregroundStyle(AppTheme.mint)
          .accessibilityHidden(true)
      }

      Button(role: .destructive) {
        store.signOut()
        authErrorMessage = nil
      } label: {
        Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.bordered)
    }
    .panel()
  }

  private var signedOutPanel: some View {
    VStack(alignment: .leading, spacing: 14) {
      SignInWithAppleButton(.continue) { request in
        request.requestedScopes = [.fullName, .email]
      } onCompletion: { result in
        handleAppleSignIn(result)
      }
      .signInWithAppleButtonStyle(.black)
      .frame(height: 50)

      Button {
        store.signInWithDemoAccount()
        authErrorMessage = nil
      } label: {
        Label("Use local demo account", systemImage: "person.crop.circle.badge.checkmark")
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.bordered)
      .controlSize(.large)

      if let authErrorMessage {
        Label(authErrorMessage, systemImage: "exclamationmark.triangle.fill")
          .font(.footnote)
          .foregroundStyle(AppTheme.coral)
          .fixedSize(horizontal: false, vertical: true)
      }

      Text("Account state is stored locally for now. Supabase can take over the same profile shape when backend sync lands.")
        .font(.footnote)
        .foregroundStyle(AppTheme.quietInk)
        .fixedSize(horizontal: false, vertical: true)
    }
    .panel()
  }

  private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
    switch result {
    case .success(let authorization):
      guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
        authErrorMessage = "Apple did not return a usable account."
        return
      }

      store.signInWithApple(
        userID: credential.user,
        displayName: credential.fullName?.profileDisplayName,
        email: credential.email
      )
      authErrorMessage = nil
    case .failure(let error):
      if let authError = error as? ASAuthorizationError, authError.code == .canceled {
        authErrorMessage = nil
        return
      }
      authErrorMessage = error.localizedDescription
    }
  }
}

private extension PersonNameComponents {
  var profileDisplayName: String? {
    let name = PersonNameComponentsFormatter.localizedString(from: self, style: .medium)
      .trimmingCharacters(in: .whitespacesAndNewlines)
    return name.isEmpty ? nil : name
  }
}
