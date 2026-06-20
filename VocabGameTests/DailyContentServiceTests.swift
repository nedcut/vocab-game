import XCTest
@testable import VocabGame

final class DailyContentServiceTests: XCTestCase {
  func testDateKeyUsesGregorianUTCDate() throws {
    let date = try makeDate(year: 2026, month: 6, day: 20)

    XCTAssertEqual(DailyContentService.dateKey(for: date), "2026-06-20")
  }

  func testSameDateProducesSamePackAndDateScopedGameIDs() throws {
    let date = try makeDate(year: 2026, month: 6, day: 20)

    let first = DailyContentService.makeGameDay(for: date)
    let second = DailyContentService.makeGameDay(for: date)

    XCTAssertEqual(first.packID, second.packID)
    XCTAssertEqual(first.games.map(\.id), second.games.map(\.id))
    XCTAssertTrue(first.games.allSatisfy { $0.id.hasPrefix("2026-06-20-") })
    XCTAssertEqual(first.games.map(\.kind.scoreKey), ["vocab-sprint", "word-wild", "odd-one-out"])
  }

  func testAdjacentDatesRotatePacks() throws {
    let firstDate = try makeDate(year: 2026, month: 6, day: 20)
    let secondDate = try makeDate(year: 2026, month: 6, day: 21)

    let first = DailyContentService.makeGameDay(for: firstDate)
    let second = DailyContentService.makeGameDay(for: secondDate)

    XCTAssertNotEqual(first.dateKey, second.dateKey)
    XCTAssertNotEqual(first.packID, second.packID)
  }

  func testEmptyPacksReturnEmptyGameDay() throws {
    let date = try makeDate(year: 2026, month: 6, day: 20)

    let gameDay = DailyContentService.makeGameDay(for: date, packs: [])

    XCTAssertEqual(gameDay.packID, "empty")
    XCTAssertTrue(gameDay.games.isEmpty)
  }

  private func makeDate(year: Int, month: Int, day: Int) throws -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
    return try XCTUnwrap(calendar.date(from: DateComponents(year: year, month: month, day: day)))
  }
}
