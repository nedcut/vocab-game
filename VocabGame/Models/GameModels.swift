import Foundation

struct GameDay: Identifiable, Hashable {
  var id: String { dateKey }
  let date: Date
  let dateKey: String
  let games: [DailyGame]
}

struct DailyGame: Identifiable, Hashable {
  let id: String
  let title: String
  let subtitle: String
  let kind: DailyGameKind
  let scoring: ScoringRule
  let questions: [VocabQuestion]
}

enum DailyGameKind: String, Hashable {
  case vocabSprint = "Vocab Sprint"
  case wordInTheWild = "Word in the Wild"
  case oddOneOut = "Odd One Out"
}

struct VocabQuestion: Identifiable, Hashable {
  let id: String
  let prompt: String
  let detail: String
  let choices: [VocabChoice]
  let correctChoiceID: String
  let explanation: String
}

struct VocabChoice: Identifiable, Hashable {
  let id: String
  let text: String
}

struct ScoringRule: Hashable {
  let maxPoints: Int
  let completionBonus: Int
  let perfectBonus: Int

  func score(correct: Int, total: Int) -> Int {
    guard total > 0 else { return 0 }
    let accuracyPoints = Int((Double(correct) / Double(total)) * Double(maxPoints))
    let earnedCompletionBonus = correct > 0 ? completionBonus : 0
    let earnedPerfectBonus = correct == total ? perfectBonus : 0
    return accuracyPoints + earnedCompletionBonus + earnedPerfectBonus
  }
}

struct GameCompletion: Identifiable, Hashable, Codable {
  var id: String { gameID }
  let gameID: String
  let score: Int
  let correct: Int
  let total: Int
  let completedAt: Date
}

enum ReminderPermissionStatus: String, Hashable, Codable {
  case unknown
  case notDetermined
  case denied
  case authorized
  case provisional
  case ephemeral

  var title: String {
    switch self {
    case .unknown: "Not checked"
    case .notDetermined: "Ready to ask"
    case .denied: "Disabled in Settings"
    case .authorized: "Allowed"
    case .provisional: "Quietly allowed"
    case .ephemeral: "Temporarily allowed"
    }
  }
}

struct FriendGroup: Identifiable, Hashable {
  let id: String
  let name: String
  let inviteCode: String
  let members: [Player]
}

struct Player: Identifiable, Hashable {
  let id: String
  let displayName: String
  let initials: String
  let colorName: String
  let dailyScores: [String: Int]
  let weeklyScores: [String: Int]
}

struct LeaderboardRow: Identifiable, Hashable {
  let id: String
  let rank: Int?
  let player: Player
  let score: Int?
  let isCurrentUser: Bool
  let hasPlayed: Bool
}
