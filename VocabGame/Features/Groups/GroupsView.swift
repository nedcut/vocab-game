import SwiftUI

struct GroupsView: View {
  @Environment(AppStore.self) private var store

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
  }
}
