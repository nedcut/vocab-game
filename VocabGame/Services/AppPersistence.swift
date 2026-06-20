import Foundation

struct AppSnapshot: Codable, Equatable {
  var selectedGroupID: String
  var completedGames: [String: GameCompletion]
  var notificationsEnabled: Bool
  var preferredReminderHour: Int
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
