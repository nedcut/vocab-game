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

  func testCreateLocalGroupSelectsAndPersistsJoinedGroup() throws {
    var savedSnapshot: AppSnapshot?
    let store = AppStore(
      persistence: AppPersistence(load: { nil }, save: { savedSnapshot = $0 })
    )

    store.createLocalGroup(named: "Book Club")

    XCTAssertEqual(store.selectedGroup.name, "Book Club")
    XCTAssertEqual(store.joinedGroups.map(\.name), ["Book Club"])
    XCTAssertEqual(savedSnapshot?.joinedGroups.map(\.name), ["Book Club"])
    XCTAssertEqual(savedSnapshot?.selectedGroupID, store.selectedGroupID)
  }

  func testJoinKnownInviteCodeSelectsExistingGroup() {
    let store = AppStore(
      persistence: AppPersistence(load: { nil }, save: { _ in })
    )

    store.joinGroup(inviteCode: "FAM-482")

    XCTAssertEqual(store.selectedGroupID, "family")
    XCTAssertTrue(store.joinedGroups.isEmpty)
  }

  func testJoinBlankInviteCodeKeepsCurrentSelection() {
    // OnboardingView disables `Start` when the invite code is blank (`canFinish`) because the
    // store deliberately ignores blank codes: `joinGroup` trims, then `guard !cleanCode.isEmpty`
    // returns early. This locks that contract so finishing onboarding in `.join` mode can never
    // silently leave the player on their default group with no group actually joined.
    let store = AppStore(
      persistence: AppPersistence(load: { nil }, save: { _ in })
    )
    let originalSelection = store.selectedGroupID

    store.joinGroup(inviteCode: "   ")

    XCTAssertEqual(store.selectedGroupID, originalSelection)
    XCTAssertTrue(store.joinedGroups.isEmpty)
  }

  func testSignInWithApplePersistsAccount() throws {
    var savedSnapshot: AppSnapshot?
    let store = AppStore(
      persistence: AppPersistence(load: { nil }, save: { savedSnapshot = $0 })
    )

    store.signInWithApple(
      userID: "apple-user-1",
      displayName: "Ned",
      email: "ned@example.com"
    )

    let account = try XCTUnwrap(store.account)
    XCTAssertEqual(account.provider, .apple)
    XCTAssertEqual(account.displayName, "Ned")
    XCTAssertEqual(account.email, "ned@example.com")
    XCTAssertEqual(savedSnapshot?.account, account)
  }

  func testRepeatedAppleSignInPreservesMissingProfileFields() throws {
    let store = AppStore(
      persistence: AppPersistence(load: { nil }, save: { _ in })
    )

    store.signInWithApple(
      userID: "apple-user-1",
      displayName: "Ned",
      email: "ned@example.com"
    )
    store.signInWithApple(
      userID: "apple-user-1",
      displayName: nil,
      email: nil
    )

    let account = try XCTUnwrap(store.account)
    XCTAssertEqual(account.displayName, "Ned")
    XCTAssertEqual(account.email, "ned@example.com")
  }

  func testSignOutClearsPersistedAccount() throws {
    let account = UserAccount(
      id: "apple-user-1",
      provider: .apple,
      displayName: "Ned",
      email: "ned@example.com",
      signedInAt: Date(timeIntervalSince1970: 1_800_000_000)
    )
    var savedSnapshot: AppSnapshot?
    let store = AppStore(
      persistence: AppPersistence(
        load: {
          AppSnapshot(
            selectedGroupID: "family",
            completedGames: [:],
            account: account,
            notificationsEnabled: false,
            preferredReminderHour: 19
          )
        },
        save: { savedSnapshot = $0 }
      )
    )

    XCTAssertNotNil(store.account)

    store.signOut()

    XCTAssertNil(store.account)
    let persistedSnapshot = try XCTUnwrap(savedSnapshot)
    XCTAssertNil(persistedSnapshot.account)
  }

  private func makeDate(year: Int, month: Int, day: Int) throws -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
    return try XCTUnwrap(calendar.date(from: DateComponents(year: year, month: month, day: day)))
  }
}
