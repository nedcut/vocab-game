import XCTest
@testable import VocabGame

@MainActor
final class AppStoreTests: XCTestCase {
  func testHydrationPrunesCompletedGamesOutsideCurrentDay() throws {
    let todayDate = try makeDate(year: 2026, month: 6, day: 20)
    let today = DailyContentService.makeGameDay(for: todayDate)
    let currentGame = try XCTUnwrap(today.games.first)
    let staleCompletion = GameCompletion(
      gameID: "2026-06-19-\(currentGame.kind.scoreKey)",
      score: 900,
      correct: 2,
      total: 3,
      completedAt: todayDate
    )
    let legacyScoreKeyCompletion = GameCompletion(
      gameID: currentGame.kind.scoreKey,
      score: 1_000,
      correct: 3,
      total: 3,
      completedAt: todayDate
    )
    let currentCompletion = GameCompletion(
      gameID: currentGame.id,
      score: 1_200,
      correct: 3,
      total: 3,
      completedAt: todayDate
    )
    let snapshot = AppSnapshot(
      selectedGroupID: "family",
      completedGames: [
        staleCompletion.gameID: staleCompletion,
        legacyScoreKeyCompletion.gameID: legacyScoreKeyCompletion,
        currentCompletion.gameID: currentCompletion
      ],
      notificationsEnabled: false,
      preferredReminderHour: 19
    )

    let store = AppStore(
      todayDate: todayDate,
      persistence: AppPersistence(load: { snapshot }, save: { _ in })
    )

    XCTAssertEqual(store.completedGames, [currentCompletion.gameID: currentCompletion])
    XCTAssertEqual(store.completion(for: currentGame), currentCompletion)
    XCTAssertEqual(store.completedTodayCount, 1)
  }

  private func makeDate(year: Int, month: Int, day: Int) throws -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
    return try XCTUnwrap(calendar.date(from: DateComponents(year: year, month: month, day: day)))
  }
}
