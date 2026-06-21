import Foundation

struct GameDay: Identifiable, Hashable {
  var id: String { dateKey }
  let date: Date
  let dateKey: String
  let packID: String
  let packTitle: String
  let packTheme: String
  let games: [DailyGame]
}

struct DailyContentPack: Identifiable, Hashable {
  let id: String
  let title: String
  let theme: String
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

  var scoreKey: String {
    switch self {
    case .vocabSprint: "vocab-sprint"
    case .wordInTheWild: "word-wild"
    case .oddOneOut: "odd-one-out"
    }
  }
}

struct VocabQuestion: Identifiable, Hashable {
  let id: String
  let prompt: String
  let detail: String
  var difficulty: WordDifficulty = .medium
  var flavor: WordFlavor = .curated
  let choices: [VocabChoice]
  let correctChoiceID: String
  let explanation: String
}

enum WordDifficulty: String, Hashable {
  case easy = "Easy"
  case medium = "Medium"
  case hard = "Hard"
}

enum WordFlavor: String, Hashable {
  case curated = "Curated"
  case fun = "Fun"
}

struct VocabChoice: Identifiable, Hashable {
  let id: String
  let text: String
}

struct ScoringRule: Hashable {
  let maxPoints: Int
  let completionBonus: Int
  let perfectBonus: Int
  var streakBonusPerWordInBestRun = 20

  func score(correct: Int, total: Int, bestStreak: Int = 0) -> Int {
    breakdown(correct: correct, total: total, bestStreak: bestStreak).total
  }

  func breakdown(correct: Int, total: Int, bestStreak: Int = 0) -> ScoreBreakdown {
    guard total > 0 else {
      return ScoreBreakdown(accuracyPoints: 0, completionBonus: 0, perfectBonus: 0, streakBonus: 0)
    }
    let accuracyPoints = Int((Double(correct) / Double(total)) * Double(maxPoints))
    let earnedCompletionBonus = correct > 0 ? completionBonus : 0
    let earnedPerfectBonus = correct == total ? perfectBonus : 0
    let clampedBestStreak = min(bestStreak, correct, total)
    let earnedStreakBonus = max(0, clampedBestStreak - 1) * streakBonusPerWordInBestRun
    return ScoreBreakdown(
      accuracyPoints: accuracyPoints,
      completionBonus: earnedCompletionBonus,
      perfectBonus: earnedPerfectBonus,
      streakBonus: earnedStreakBonus
    )
  }

  func maxScore(questionCount: Int) -> Int {
    score(correct: questionCount, total: questionCount, bestStreak: questionCount)
  }
}

struct ScoreBreakdown: Hashable, Codable {
  let accuracyPoints: Int
  let completionBonus: Int
  let perfectBonus: Int
  let streakBonus: Int

  var total: Int {
    accuracyPoints + completionBonus + perfectBonus + streakBonus
  }
}

struct GameCompletion: Identifiable, Hashable, Codable {
  var id: String { gameID }
  let gameID: String
  let score: Int
  let correct: Int
  let total: Int
  let bestStreak: Int
  let scoreBreakdown: ScoreBreakdown?
  let completedAt: Date

  init(
    gameID: String,
    score: Int,
    correct: Int,
    total: Int,
    bestStreak: Int = 0,
    scoreBreakdown: ScoreBreakdown? = nil,
    completedAt: Date
  ) {
    self.gameID = gameID
    self.score = score
    self.correct = correct
    self.total = total
    self.bestStreak = bestStreak
    self.scoreBreakdown = scoreBreakdown
    self.completedAt = completedAt
  }

  private enum CodingKeys: String, CodingKey {
    case gameID
    case score
    case correct
    case total
    case bestStreak
    case scoreBreakdown
    case completedAt
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    gameID = try container.decode(String.self, forKey: .gameID)
    score = try container.decode(Int.self, forKey: .score)
    correct = try container.decode(Int.self, forKey: .correct)
    total = try container.decode(Int.self, forKey: .total)
    bestStreak = try container.decodeIfPresent(Int.self, forKey: .bestStreak) ?? 0
    scoreBreakdown = try container.decodeIfPresent(ScoreBreakdown.self, forKey: .scoreBreakdown)
    completedAt = try container.decode(Date.self, forKey: .completedAt)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(gameID, forKey: .gameID)
    try container.encode(score, forKey: .score)
    try container.encode(correct, forKey: .correct)
    try container.encode(total, forKey: .total)
    try container.encode(bestStreak, forKey: .bestStreak)
    try container.encodeIfPresent(scoreBreakdown, forKey: .scoreBreakdown)
    try container.encode(completedAt, forKey: .completedAt)
  }
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

struct FriendGroup: Identifiable, Hashable, Codable {
  let id: String
  let name: String
  let inviteCode: String
  let members: [Player]
}

struct Player: Identifiable, Hashable, Codable {
  let id: String
  let displayName: String
  let initials: String
  let colorName: String
  let dailyScores: [String: Int]
  let weeklyScores: [String: Int]
}

struct UserAccount: Identifiable, Hashable, Codable {
  let id: String
  let provider: AccountProvider
  let displayName: String
  let email: String?
  let signedInAt: Date
}

enum AccountProvider: String, Hashable, Codable {
  case apple
  case localDemo

  var title: String {
    switch self {
    case .apple: "Apple"
    case .localDemo: "Local demo"
    }
  }
}

struct LeaderboardRow: Identifiable, Hashable {
  let id: String
  let rank: Int?
  let player: Player
  let score: Int?
  let isCurrentUser: Bool
  let hasPlayed: Bool
}
