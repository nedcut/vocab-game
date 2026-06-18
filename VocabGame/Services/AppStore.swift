import Foundation
import Observation

@MainActor
@Observable
final class AppStore {
  var selectedGroupID = SampleData.groups[0].id
  var completedGames: [String: GameCompletion] = [:]
  var notificationsEnabled = true
  var preferredReminderHour = 19

  let today = SampleData.today
  let groups = SampleData.groups
  let currentUser = SampleData.currentUser

  var selectedGroup: FriendGroup {
    groups.first { $0.id == selectedGroupID } ?? groups[0]
  }

  func completion(for game: DailyGame) -> GameCompletion? {
    completedGames[game.id]
  }

  func complete(game: DailyGame, correct: Int, total: Int) {
    let score = game.scoring.score(correct: correct, total: total)
    completedGames[game.id] = GameCompletion(
      gameID: game.id,
      score: score,
      correct: correct,
      total: total,
      completedAt: Date()
    )
  }

  func dailyLeaderboard(for game: DailyGame) -> [LeaderboardRow] {
    let revealScores = completedGames[game.id] != nil
    var rows: [LeaderboardRow] = selectedGroup.members.map { player in
      if player.id == currentUser.id {
        let completion = completedGames[game.id]
        return LeaderboardRow(
          id: player.id,
          rank: nil,
          player: player,
          score: completion?.score,
          isCurrentUser: true,
          hasPlayed: completion != nil
        )
      }

      let score = player.dailyScores[game.id]
      return LeaderboardRow(
        id: player.id,
        rank: nil,
        player: player,
        score: revealScores ? score : nil,
        isCurrentUser: false,
        hasPlayed: score != nil
      )
    }

    if revealScores {
      rows.sort { ($0.score ?? -1) > ($1.score ?? -1) }
      rows = rows.enumerated().map { index, row in
        LeaderboardRow(
          id: row.id,
          rank: row.score == nil ? nil : index + 1,
          player: row.player,
          score: row.score,
          isCurrentUser: row.isCurrentUser,
          hasPlayed: row.hasPlayed
        )
      }
    }

    return rows
  }

  func weeklyLeaderboard(gameID: String? = nil) -> [LeaderboardRow] {
    let rows = selectedGroup.members.map { player in
      let baseScore: Int
      if let gameID {
        baseScore = player.weeklyScores[gameID] ?? 0
      } else {
        baseScore = player.weeklyScores.values.reduce(0, +)
      }

      let currentBoost = player.id == currentUser.id
        ? completedGames.values.reduce(0) { $0 + $1.score }
        : 0

      return LeaderboardRow(
        id: player.id,
        rank: nil,
        player: player,
        score: baseScore + currentBoost,
        isCurrentUser: player.id == currentUser.id,
        hasPlayed: true
      )
    }
    .sorted { ($0.score ?? 0) > ($1.score ?? 0) }

    return rows.enumerated().map { index, row in
      LeaderboardRow(
        id: row.id,
        rank: index + 1,
        player: row.player,
        score: row.score,
        isCurrentUser: row.isCurrentUser,
        hasPlayed: row.hasPlayed
      )
    }
  }
}
