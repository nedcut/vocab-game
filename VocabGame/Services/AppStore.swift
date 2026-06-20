import Foundation
import Observation

@MainActor
@Observable
final class AppStore {
  var selectedGroupID = SampleData.groups[0].id {
    didSet { persistIfHydrated() }
  }

  var completedGames: [String: GameCompletion] = [:] {
    didSet { persistIfHydrated() }
  }

  var notificationsEnabled = false {
    didSet {
      guard isHydrated else { return }
      persist()
      Task { await syncReminder() }
    }
  }

  var preferredReminderHour = 19 {
    didSet {
      guard isHydrated else { return }
      persist()
      Task { await syncReminder() }
    }
  }

  private(set) var reminderStatus: ReminderPermissionStatus = .unknown
  private(set) var reminderMessage = "Daily reminder is off."

  let today: GameDay
  let groups = SampleData.groups
  let currentUser = SampleData.currentUser

  private let persistence: AppPersistence
  private let reminderScheduler: ReminderNotificationScheduler

  // `@Observable` rewrites stored properties so their `didSet` observers fire even
  // when assigned inside `init`. Gate the persistence/scheduling side effects on this
  // flag so hydrating from a snapshot only restores state instead of rewriting it and
  // kicking off duplicate reminder syncs before `prepareForLaunch()` runs.
  @ObservationIgnored private var isHydrated = false

  init(
    todayDate: Date = Date(),
    contentService: DailyContentService = .live,
    persistence: AppPersistence = .live,
    reminderScheduler: ReminderNotificationScheduler = ReminderNotificationScheduler()
  ) {
    self.today = contentService.gameDay(todayDate)
    self.persistence = persistence
    self.reminderScheduler = reminderScheduler

    if let snapshot = persistence.load() {
      selectedGroupID = groups.contains { $0.id == snapshot.selectedGroupID }
        ? snapshot.selectedGroupID
        : groups[0].id
      completedGames = Self.currentDayCompletions(from: snapshot.completedGames, dateKey: today.dateKey)
      notificationsEnabled = snapshot.notificationsEnabled
      preferredReminderHour = snapshot.preferredReminderHour
    }

    isHydrated = true
  }

  var selectedGroup: FriendGroup {
    groups.first { $0.id == selectedGroupID } ?? groups[0]
  }

  var completedTodayCount: Int {
    today.games.filter { completion(for: $0) != nil }.count
  }

  var allTodayGamesCompleted: Bool {
    completedTodayCount == today.games.count
  }

  var totalScoreToday: Int {
    today.games.reduce(0) { total, game in
      total + (completion(for: game)?.score ?? 0)
    }
  }

  func prepareForLaunch() async {
    reminderStatus = await reminderScheduler.currentStatus()
    if notificationsEnabled {
      await syncReminder()
    }
  }

  func completion(for game: DailyGame) -> GameCompletion? {
    // Look up only by the date-scoped game id. `completedGames` stores the local
    // player's own results, always keyed by `game.id`, so completions reset per day.
    // Falling back to the stable `scoreKey` here would match stale entries from an
    // earlier build and make a game read as completed every day forever.
    completedGames[game.id]
  }

  func complete(game: DailyGame, correct: Int, total: Int, bestStreak: Int) {
    let breakdown = game.scoring.breakdown(correct: correct, total: total, bestStreak: bestStreak)
    completedGames[game.id] = GameCompletion(
      gameID: game.id,
      score: breakdown.total,
      correct: correct,
      total: total,
      bestStreak: bestStreak,
      scoreBreakdown: breakdown,
      completedAt: Date()
    )
  }

  func dailyAggregateLeaderboard() -> [LeaderboardRow]? {
    guard allTodayGamesCompleted else {
      return nil
    }

    let rows = selectedGroup.members.map { player in
      let score: Int
      if player.id == currentUser.id {
        score = totalScoreToday
      } else {
        score = today.games.reduce(0) { total, game in
          total + (player.dailyScores[game.kind.scoreKey] ?? 0)
        }
      }

      return LeaderboardRow(
        id: player.id,
        rank: nil,
        player: player,
        score: score,
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
        ?? player.dailyScores[game.kind.scoreKey]
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
        let scoreKey = today.games.first { $0.id == gameID }?.kind.scoreKey ?? gameID
        baseScore = player.weeklyScores[scoreKey] ?? 0
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

  private func persistIfHydrated() {
    guard isHydrated else { return }
    persist()
  }

  private func persist() {
    persistence.save(AppSnapshot(
      selectedGroupID: selectedGroupID,
      completedGames: completedGames,
      notificationsEnabled: notificationsEnabled,
      preferredReminderHour: preferredReminderHour
    ))
  }

  private static func currentDayCompletions(
    from completions: [String: GameCompletion],
    dateKey: String
  ) -> [String: GameCompletion] {
    let currentDayPrefix = "\(dateKey)-"
    return completions.filter { key, completion in
      key.hasPrefix(currentDayPrefix) && completion.gameID == key
    }
  }

  private func syncReminder() async {
    let result = await reminderScheduler.sync(enabled: notificationsEnabled, hour: preferredReminderHour)
    reminderStatus = result.status
    reminderMessage = result.message
  }
}
