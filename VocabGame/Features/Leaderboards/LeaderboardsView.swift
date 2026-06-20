import SwiftUI

struct LeaderboardsView: View {
  @Environment(AppStore.self) private var store
  @State private var scope: LeaderboardScope = .daily
  @State private var selectedGameID = SampleData.today.games[0].id

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 18) {
        VStack(alignment: .leading, spacing: 8) {
          Text("Leaderboards")
            .font(.largeTitle.weight(.bold))
          Text(store.selectedGroup.name)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppTheme.quietInk)
        }

        Picker("Scope", selection: $scope) {
          ForEach(LeaderboardScope.allCases) { scope in
            Text(scope.title).tag(scope)
          }
        }
        .pickerStyle(.segmented)

        Picker("Game", selection: $selectedGameID) {
          Text("Aggregate").tag("aggregate")
          ForEach(store.today.games) { game in
            Text(game.title).tag(game.id)
          }
        }
        .pickerStyle(.menu)

        leaderboard
      }
      .padding(20)
    }
    .background(AppTheme.background)
    .navigationTitle("Leaders")
  }

  @ViewBuilder
  private var leaderboard: some View {
    switch scope {
    case .daily:
      if selectedGameID == "aggregate" {
        if let rows = store.dailyAggregateLeaderboard() {
          LeaderboardList(
            title: "Daily aggregate",
            rows: rows,
            hidesScoresUntilPlayed: false
          )
        } else {
          VStack(alignment: .leading, spacing: 10) {
            Text("Daily aggregate unlocks after every game is finished.")
              .font(.headline)
            Text("\(store.completedTodayCount) of \(store.today.games.count) games complete.")
              .font(.subheadline)
              .foregroundStyle(AppTheme.quietInk)
          }
          .panel()
        }
      } else if let game = store.today.games.first(where: { $0.id == selectedGameID }) {
        LeaderboardList(
          title: game.title,
          rows: store.dailyLeaderboard(for: game),
          hidesScoresUntilPlayed: store.completion(for: game) == nil
        )
      }
    case .weekly:
      LeaderboardList(
        title: selectedGameID == "aggregate" ? "Weekly aggregate" : "Weekly \(title(for: selectedGameID))",
        rows: store.weeklyLeaderboard(gameID: selectedGameID == "aggregate" ? nil : selectedGameID),
        hidesScoresUntilPlayed: false
      )
    }
  }

  private func title(for gameID: String) -> String {
    store.today.games.first { $0.id == gameID }?.title ?? "Game"
  }
}

private enum LeaderboardScope: String, CaseIterable, Identifiable {
  case daily
  case weekly

  var id: String { rawValue }

  var title: String {
    switch self {
    case .daily: "Daily"
    case .weekly: "Weekly"
    }
  }
}

struct LeaderboardList: View {
  let title: String
  let rows: [LeaderboardRow]
  let hidesScoresUntilPlayed: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack {
        Text(title)
          .font(.headline)
        Spacer()
        if hidesScoresUntilPlayed {
          Label("No spoilers", systemImage: "eye.slash.fill")
            .font(.caption.weight(.semibold))
            .foregroundStyle(AppTheme.quietInk)
        }
      }

      ForEach(rows) { row in
        HStack(spacing: 12) {
          Text(rankText(for: row))
            .font(.subheadline.monospacedDigit().weight(.bold))
            .foregroundStyle(AppTheme.quietInk)
            .frame(width: 28, alignment: .leading)

          AvatarView(player: row.player, size: 38)

          VStack(alignment: .leading, spacing: 2) {
            Text(row.player.displayName)
              .font(.body.weight(row.isCurrentUser ? .bold : .semibold))
            if !row.hasPlayed {
              Text("Not played yet")
                .font(.caption)
                .foregroundStyle(AppTheme.quietInk)
            }
          }

          Spacer()

          Text(scoreText(for: row))
            .font(.body.monospacedDigit().weight(.bold))
            .foregroundStyle(row.score == nil ? AppTheme.quietInk : AppTheme.ink)
        }
        .padding(.vertical, 4)
      }
    }
    .panel()
  }

  private func rankText(for row: LeaderboardRow) -> String {
    guard let rank = row.rank else { return "-" }
    return "#\(rank)"
  }

  private func scoreText(for row: LeaderboardRow) -> String {
    guard let score = row.score else {
      return row.hasPlayed ? "Hidden" : "-"
    }
    return "\(score)"
  }
}
