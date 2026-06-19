import SwiftUI
import UIKit

struct GroupsView: View {
  @Environment(AppStore.self) private var store
  @State private var inviteGroup: FriendGroup?

  var body: some View {
    @Bindable var store = store

    ScrollView {
      VStack(alignment: .leading, spacing: 18) {
        VStack(alignment: .leading, spacing: 8) {
          Text("Your groups")
            .font(.largeTitle.weight(.bold))
          Text("Play the same daily set with each circle. Scores and streaks stay inside that group.")
            .font(.subheadline)
            .foregroundStyle(AppTheme.quietInk)
        }

        Picker("Selected group", selection: $store.selectedGroupID) {
          ForEach(store.groups) { group in
            Text(group.name).tag(group.id)
          }
        }
        .pickerStyle(.segmented)

        VStack(alignment: .leading, spacing: 14) {
          HStack {
            Text(store.selectedGroup.name)
              .font(.title3.weight(.bold))
            Spacer()
            Label(store.selectedGroup.inviteCode, systemImage: "link")
              .font(.caption.weight(.bold))
              .foregroundStyle(AppTheme.blue)
          }

          ForEach(store.selectedGroup.members) { member in
            HStack(spacing: 12) {
              AvatarView(player: member, size: 44)
              VStack(alignment: .leading, spacing: 3) {
                Text(member.displayName)
                  .font(.body.weight(.semibold))
                Text(member.id == store.currentUser.id ? "You" : "Friend")
                  .font(.caption)
                  .foregroundStyle(AppTheme.quietInk)
              }
              Spacer()
              Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(AppTheme.quietInk)
            }
            .padding(.vertical, 4)
          }
        }
        .panel()

        Button {
          inviteGroup = store.selectedGroup
        } label: {
          Label("Invite people", systemImage: "person.badge.plus")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
      }
      .padding(20)
    }
    .background(AppTheme.background)
    .navigationTitle("Groups")
    .sheet(item: $inviteGroup) { group in
      GroupInviteSheet(group: group)
    }
  }
}

private struct GroupInviteSheet: View {
  @Environment(\.dismiss) private var dismiss

  let group: FriendGroup

  @State private var didCopy = false

  private var inviteText: String {
    "Join my \(group.name) daily vocab group with code \(group.inviteCode)."
  }

  var body: some View {
    NavigationStack {
      VStack(alignment: .leading, spacing: 18) {
        VStack(alignment: .leading, spacing: 8) {
          Text("Invite to \(group.name)")
            .font(.title.weight(.bold))
          Text("Share this code with family or friends. In the backend version, this becomes a magic invite link.")
            .font(.subheadline)
            .foregroundStyle(AppTheme.quietInk)
            .fixedSize(horizontal: false, vertical: true)
        }

        VStack(alignment: .leading, spacing: 10) {
          Text("Group code")
            .font(.headline)
          Text(group.inviteCode)
            .font(.system(size: 34, weight: .bold, design: .rounded).monospaced())
            .frame(maxWidth: .infinity, alignment: .leading)
            .textSelection(.enabled)
        }
        .panel()

        Button {
          UIPasteboard.general.string = group.inviteCode
          withAnimation { didCopy = true }
          Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation { didCopy = false }
          }
        } label: {
          Label(didCopy ? "Copied" : "Copy code", systemImage: didCopy ? "checkmark.circle.fill" : "doc.on.doc.fill")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)

        ShareLink(item: inviteText) {
          Label("Share invite", systemImage: "square.and.arrow.up")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)

        Spacer()
      }
      .padding(20)
      .background(AppTheme.background)
      .navigationTitle("Invite")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") {
            dismiss()
          }
        }
      }
    }
    .presentationDetents([.medium, .large])
  }
}
