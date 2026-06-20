import Foundation

enum SampleData {
  static let currentUser = Player(
    id: "you",
    displayName: "You",
    initials: "NC",
    colorName: "mint",
    dailyScores: [:],
    weeklyScores: ["vocab-sprint": 2860, "word-wild": 2260, "odd-one-out": 1740]
  )

  static let groups: [FriendGroup] = [
    FriendGroup(
      id: "family",
      name: "Family",
      inviteCode: "FAM-482",
      members: [
        currentUser,
        Player(
          id: "mom",
          displayName: "Mom",
          initials: "MA",
          colorName: "coral",
          dailyScores: ["vocab-sprint": 950, "word-wild": 780, "odd-one-out": 620],
          weeklyScores: ["vocab-sprint": 3320, "word-wild": 2980, "odd-one-out": 2440]
        ),
        Player(
          id: "dad",
          displayName: "Dad",
          initials: "DA",
          colorName: "gold",
          dailyScores: ["vocab-sprint": 700, "word-wild": 950],
          weeklyScores: ["vocab-sprint": 3010, "word-wild": 2720, "odd-one-out": 2060]
        ),
        Player(
          id: "maya",
          displayName: "Maya",
          initials: "MK",
          colorName: "blue",
          dailyScores: ["vocab-sprint": 1250, "word-wild": 950, "odd-one-out": 850],
          weeklyScores: ["vocab-sprint": 3540, "word-wild": 3120, "odd-one-out": 2690]
        )
      ]
    ),
    FriendGroup(
      id: "friends",
      name: "Sunday Crew",
      inviteCode: "SUN-119",
      members: [
        currentUser,
        Player(
          id: "eli",
          displayName: "Eli",
          initials: "EL",
          colorName: "blue",
          dailyScores: ["vocab-sprint": 1050, "word-wild": 590],
          weeklyScores: ["vocab-sprint": 3100, "word-wild": 2510, "odd-one-out": 2100]
        ),
        Player(
          id: "ruth",
          displayName: "Ruth",
          initials: "RT",
          colorName: "coral",
          dailyScores: ["vocab-sprint": 840, "word-wild": 950, "odd-one-out": 700],
          weeklyScores: ["vocab-sprint": 2920, "word-wild": 3220, "odd-one-out": 2370]
        )
      ]
    )
  ]
}
