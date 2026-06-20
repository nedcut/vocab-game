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

  func testStreakBonusRewardsBestRunAfterFirstWord() {
    let rule = ScoringRule(maxPoints: 900, completionBonus: 100, perfectBonus: 250)

    let breakdown = rule.breakdown(correct: 2, total: 3, bestStreak: 2)

    XCTAssertEqual(breakdown.accuracyPoints, 600)
    XCTAssertEqual(breakdown.completionBonus, 100)
    XCTAssertEqual(breakdown.streakBonus, 20)
    XCTAssertEqual(breakdown.total, 720)
  }

  func testMaxScoreIncludesPerfectStreakBonus() {
    let rule = ScoringRule(maxPoints: 900, completionBonus: 100, perfectBonus: 250)

    XCTAssertEqual(rule.maxScore(questionCount: 3), 1_290)
  }

  func testStreakBonusIsCappedByCorrectAnswers() {
    let rule = ScoringRule(maxPoints: 900, completionBonus: 100, perfectBonus: 250)

    let breakdown = rule.breakdown(correct: 1, total: 3, bestStreak: 3)

    XCTAssertEqual(breakdown.streakBonus, 0)
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
      bestStreak: 3,
      scoreBreakdown: ScoreBreakdown(
        accuracyPoints: 900,
        completionBonus: 100,
        perfectBonus: 250,
        streakBonus: 40
      ),
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

  func testLegacySnapshotDecodesWithoutOnboardingFields() throws {
    let json = """
      {
        "selectedGroupID": "family",
        "completedGames": {},
        "notificationsEnabled": false,
        "preferredReminderHour": 19
      }
      """
    let data = try XCTUnwrap(json.data(using: .utf8))

    let snapshot = try JSONDecoder().decode(AppSnapshot.self, from: data)

    XCTAssertEqual(snapshot.selectedGroupID, "family")
    XCTAssertTrue(snapshot.joinedGroups.isEmpty)
    XCTAssertFalse(snapshot.hasCompletedOnboarding)
  }

  func testLegacyGameCompletionDecodesWithoutStreakMetadata() throws {
    let json = """
      {
        "gameID": "vocab-sprint",
        "score": 1250,
        "correct": 3,
        "total": 3,
        "completedAt": 1800000000
      }
      """
    let data = try XCTUnwrap(json.data(using: .utf8))

    let completion = try JSONDecoder().decode(GameCompletion.self, from: data)

    XCTAssertEqual(completion.gameID, "vocab-sprint")
    XCTAssertEqual(completion.bestStreak, 0)
    XCTAssertNil(completion.scoreBreakdown)
  }
}
