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
}
