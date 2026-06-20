import Foundation

struct AppSnapshot: Codable, Equatable {
  var selectedGroupID: String
  var joinedGroups: [FriendGroup]
  var completedGames: [String: GameCompletion]
  var hasCompletedOnboarding: Bool
  var notificationsEnabled: Bool
  var preferredReminderHour: Int

  init(
    selectedGroupID: String,
    joinedGroups: [FriendGroup] = [],
    completedGames: [String: GameCompletion],
    hasCompletedOnboarding: Bool = false,
    notificationsEnabled: Bool,
    preferredReminderHour: Int
  ) {
    self.selectedGroupID = selectedGroupID
    self.joinedGroups = joinedGroups
    self.completedGames = completedGames
    self.hasCompletedOnboarding = hasCompletedOnboarding
    self.notificationsEnabled = notificationsEnabled
    self.preferredReminderHour = preferredReminderHour
  }

  private enum CodingKeys: String, CodingKey {
    case selectedGroupID
    case joinedGroups
    case completedGames
    case hasCompletedOnboarding
    case notificationsEnabled
    case preferredReminderHour
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    selectedGroupID = try container.decode(String.self, forKey: .selectedGroupID)
    joinedGroups = try container.decodeIfPresent([FriendGroup].self, forKey: .joinedGroups) ?? []
    completedGames = try container.decode([String: GameCompletion].self, forKey: .completedGames)
    hasCompletedOnboarding = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? false
    notificationsEnabled = try container.decode(Bool.self, forKey: .notificationsEnabled)
    preferredReminderHour = try container.decode(Int.self, forKey: .preferredReminderHour)
  }
}

struct AppPersistence {
  var load: () -> AppSnapshot?
  var save: (AppSnapshot) -> Void

  static let live = AppPersistence(
    load: {
      guard let data = UserDefaults.standard.data(forKey: storageKey) else {
        return nil
      }

      return try? JSONDecoder().decode(AppSnapshot.self, from: data)
    },
    save: { snapshot in
      guard let data = try? JSONEncoder().encode(snapshot) else {
        return
      }

      UserDefaults.standard.set(data, forKey: storageKey)
    }
  )
}

private let storageKey = "vocab-game.app-snapshot.v1"
