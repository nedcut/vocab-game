import XCTest
@testable import VocabGame

final class ScoringRuleTests: XCTestCase {
  func testPerfectScoreIncludesCompletionAndPerfectBonuses() {
    let rule = ScoringRule(maxPoints: 900, completionBonus: 100, perfectBonus: 250)

    XCTAssertEqual(rule.score(correct: 3, total: 3), 1250)
  }

  func testPartialScoreIncludesAccuracyAndCompletionBonus() {
    let rule = ScoringRule(maxPoints: 900, completionBonus: 100, perfectBonus: 250)

    XCTAssertEqual(rule.score(correct: 2, total: 3), 700)
  }

  func testZeroCorrectEarnsZero() {
    let rule = ScoringRule(maxPoints: 900, completionBonus: 100, perfectBonus: 250)

    XCTAssertEqual(rule.score(correct: 0, total: 3), 0)
  }

  func testGameCompletionRoundTripsThroughSnapshotEncoding() throws {
    let completion = GameCompletion(
      gameID: "vocab-sprint",
      score: 1250,
      correct: 3,
      total: 3,
      completedAt: Date(timeIntervalSince1970: 1_800_000_000)
    )
    let snapshot = AppSnapshot(
      selectedGroupID: "family",
      completedGames: [completion.gameID: completion],
      notificationsEnabled: true,
      preferredReminderHour: 19
    )

    let data = try JSONEncoder().encode(snapshot)
    let decoded = try JSONDecoder().decode(AppSnapshot.self, from: data)

    XCTAssertEqual(decoded, snapshot)
  }
}
