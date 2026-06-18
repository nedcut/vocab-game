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

  static let today = GameDay(
    date: Date(),
    dateKey: "2026-06-18",
    games: [
      DailyGame(
        id: "vocab-sprint",
        title: "Vocab Sprint",
        subtitle: "Pick the closest meaning.",
        kind: .vocabSprint,
        scoring: ScoringRule(maxPoints: 900, completionBonus: 100, perfectBonus: 250),
        questions: [
          VocabQuestion(
            id: "pellucid",
            prompt: "pellucid",
            detail: "What does this word mean?",
            choices: [
              VocabChoice(id: "a", text: "Clear and easy to understand"),
              VocabChoice(id: "b", text: "Needlessly aggressive"),
              VocabChoice(id: "c", text: "Recently invented"),
              VocabChoice(id: "d", text: "Likely to vanish")
            ],
            correctChoiceID: "a",
            explanation: "Pellucid means transparent, lucid, or easy to understand."
          ),
          VocabQuestion(
            id: "garrulous",
            prompt: "garrulous",
            detail: "Choose the best definition.",
            choices: [
              VocabChoice(id: "a", text: "Stubbornly loyal"),
              VocabChoice(id: "b", text: "Excessively talkative"),
              VocabChoice(id: "c", text: "Oddly graceful"),
              VocabChoice(id: "d", text: "Barely awake")
            ],
            correctChoiceID: "b",
            explanation: "A garrulous person talks a lot, often more than people wanted."
          ),
          VocabQuestion(
            id: "liminal",
            prompt: "liminal",
            detail: "What is the closest meaning?",
            choices: [
              VocabChoice(id: "a", text: "Sacred and untouchable"),
              VocabChoice(id: "b", text: "At a threshold or transition"),
              VocabChoice(id: "c", text: "Made from stone"),
              VocabChoice(id: "d", text: "Full of tiny errors")
            ],
            correctChoiceID: "b",
            explanation: "Liminal describes a threshold state, between one thing and another."
          )
        ]
      ),
      DailyGame(
        id: "word-wild",
        title: "Word in the Wild",
        subtitle: "Use context to find the meaning.",
        kind: .wordInTheWild,
        scoring: ScoringRule(maxPoints: 800, completionBonus: 150, perfectBonus: 200),
        questions: [
          VocabQuestion(
            id: "susurrus",
            prompt: "The susurrus of rain made the room feel private.",
            detail: "What does susurrus suggest?",
            choices: [
              VocabChoice(id: "a", text: "A soft whispering sound"),
              VocabChoice(id: "b", text: "A sudden bright flash"),
              VocabChoice(id: "c", text: "A bitter smell"),
              VocabChoice(id: "d", text: "A formal announcement")
            ],
            correctChoiceID: "a",
            explanation: "Susurrus is a whispering, rustling, or murmuring sound."
          ),
          VocabQuestion(
            id: "jejune",
            prompt: "The plan sounded bold, but the details were jejune.",
            detail: "What does jejune mean here?",
            choices: [
              VocabChoice(id: "a", text: "Childish or simplistic"),
              VocabChoice(id: "b", text: "Technically illegal"),
              VocabChoice(id: "c", text: "Beautifully timed"),
              VocabChoice(id: "d", text: "Old but reliable")
            ],
            correctChoiceID: "a",
            explanation: "Jejune can mean naive, simplistic, or lacking substance."
          )
        ]
      ),
      DailyGame(
        id: "odd-one-out",
        title: "Odd One Out",
        subtitle: "Spot the word that breaks the set.",
        kind: .oddOneOut,
        scoring: ScoringRule(maxPoints: 600, completionBonus: 100, perfectBonus: 150),
        questions: [
          VocabQuestion(
            id: "fast-set",
            prompt: "Which word does not mean fast?",
            detail: "Choose the odd one out.",
            choices: [
              VocabChoice(id: "a", text: "Fleet"),
              VocabChoice(id: "b", text: "Brisk"),
              VocabChoice(id: "c", text: "Tardy"),
              VocabChoice(id: "d", text: "Rapid")
            ],
            correctChoiceID: "c",
            explanation: "Tardy means late or delayed, not fast."
          ),
          VocabQuestion(
            id: "praise-set",
            prompt: "Which word is not praise?",
            detail: "Choose the odd one out.",
            choices: [
              VocabChoice(id: "a", text: "Plaudit"),
              VocabChoice(id: "b", text: "Kudos"),
              VocabChoice(id: "c", text: "Acclaim"),
              VocabChoice(id: "d", text: "Censure")
            ],
            correctChoiceID: "d",
            explanation: "Censure is strong criticism or disapproval."
          )
        ]
      )
    ]
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
