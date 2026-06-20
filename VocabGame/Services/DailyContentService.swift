import Foundation

struct DailyContentService {
  var gameDay: (Date) -> GameDay

  static let live = DailyContentService { date in
    makeGameDay(for: date)
  }

  static func makeGameDay(
    for date: Date,
    calendar: Calendar = dailyCalendar,
    packs: [DailyContentPack] = starterPacks
  ) -> GameDay {
    let normalizedDate = calendar.startOfDay(for: date)
    let dateKey = Self.dateKey(for: normalizedDate, calendar: calendar)
    guard let pack = pack(for: normalizedDate, calendar: calendar, packs: packs) else {
      return GameDay(date: normalizedDate, dateKey: dateKey, packID: "empty", packTitle: "No pack", packTheme: "No games scheduled.", games: [])
    }

    return GameDay(
      date: normalizedDate,
      dateKey: dateKey,
      packID: pack.id,
      packTitle: pack.title,
      packTheme: pack.theme,
      games: pack.games.map { game in
        DailyGame(
          id: "\(dateKey)-\(game.kind.scoreKey)",
          title: game.title,
          subtitle: game.subtitle,
          kind: game.kind,
          scoring: game.scoring,
          questions: game.questions
        )
      }
    )
  }

  static func pack(
    for date: Date,
    calendar: Calendar = dailyCalendar,
    packs: [DailyContentPack] = starterPacks
  ) -> DailyContentPack? {
    guard !packs.isEmpty else { return nil }
    let normalizedDate = calendar.startOfDay(for: date)
    let referenceDate = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)) ?? normalizedDate
    let dayOffset = calendar.dateComponents([.day], from: referenceDate, to: normalizedDate).day ?? 0
    let index = positiveModulo(dayOffset, packs.count)
    return packs[index]
  }

  static func dateKey(for date: Date, calendar: Calendar = dailyCalendar) -> String {
    let components = calendar.dateComponents([.year, .month, .day], from: date)
    let year = components.year ?? 1970
    let month = components.month ?? 1
    let day = components.day ?? 1
    return String(format: "%04d-%02d-%02d", year, month, day)
  }

  private static func positiveModulo(_ value: Int, _ divisor: Int) -> Int {
    let remainder = value % divisor
    return remainder >= 0 ? remainder : remainder + divisor
  }
}

private var dailyCalendar: Calendar {
  var calendar = Calendar(identifier: .gregorian)
  calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
  return calendar
}

extension DailyContentService {
  static let starterPacks: [DailyContentPack] = [
    DailyContentPack(
      id: "clear-thresholds",
      title: "Clear Thresholds",
      theme: "Lucid words, transitional states, and classic odd-one-outs.",
      games: [
        DailyGame(
          id: DailyGameKind.vocabSprint.scoreKey,
          title: "Vocab Sprint",
          subtitle: "Pick the closest meaning.",
          kind: .vocabSprint,
          scoring: ScoringRule(maxPoints: 900, completionBonus: 100, perfectBonus: 250),
          questions: [
            VocabQuestion(
              id: "pellucid",
              prompt: "pellucid",
              detail: "What does this word mean?",
              difficulty: .medium,
              flavor: .curated,
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
              difficulty: .medium,
              flavor: .curated,
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
              difficulty: .medium,
              flavor: .curated,
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
          id: DailyGameKind.wordInTheWild.scoreKey,
          title: "Word in the Wild",
          subtitle: "Use context to find the meaning.",
          kind: .wordInTheWild,
          scoring: ScoringRule(maxPoints: 800, completionBonus: 150, perfectBonus: 200),
          questions: [
            VocabQuestion(
              id: "susurrus",
              prompt: "The susurrus of rain made the room feel private.",
              detail: "What does susurrus suggest?",
              difficulty: .hard,
              flavor: .curated,
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
              difficulty: .hard,
              flavor: .curated,
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
          id: DailyGameKind.oddOneOut.scoreKey,
          title: "Odd One Out",
          subtitle: "Spot the word that breaks the set.",
          kind: .oddOneOut,
          scoring: ScoringRule(maxPoints: 600, completionBonus: 100, perfectBonus: 150),
          questions: [
            VocabQuestion(
              id: "fast-set",
              prompt: "Which word does not mean fast?",
              detail: "Choose the odd one out.",
              difficulty: .easy,
              flavor: .curated,
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
              difficulty: .easy,
              flavor: .curated,
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
    ),
    DailyContentPack(
      id: "party-tricks",
      title: "Party Tricks",
      theme: "Useful fancy words plus a few unserious favorites.",
      games: [
        DailyGame(
          id: DailyGameKind.vocabSprint.scoreKey,
          title: "Vocab Sprint",
          subtitle: "Pick the closest meaning.",
          kind: .vocabSprint,
          scoring: ScoringRule(maxPoints: 900, completionBonus: 100, perfectBonus: 250),
          questions: [
            VocabQuestion(
              id: "defenestrate",
              prompt: "defenestrate",
              detail: "Choose the best definition.",
              difficulty: .hard,
              flavor: .fun,
              choices: [
                VocabChoice(id: "a", text: "Throw out of a window"),
                VocabChoice(id: "b", text: "Make a room darker"),
                VocabChoice(id: "c", text: "Debate politely"),
                VocabChoice(id: "d", text: "Invent a fake title")
              ],
              correctChoiceID: "a",
              explanation: "To defenestrate is to throw someone or something out of a window."
            ),
            VocabQuestion(
              id: "callipygian",
              prompt: "callipygian",
              detail: "What does this extremely specific word describe?",
              difficulty: .hard,
              flavor: .fun,
              choices: [
                VocabChoice(id: "a", text: "Having shapely buttocks"),
                VocabChoice(id: "b", text: "Speaking in riddles"),
                VocabChoice(id: "c", text: "Afraid of clocks"),
                VocabChoice(id: "d", text: "Beautifully handwritten")
              ],
              correctChoiceID: "a",
              explanation: "Callipygian means having well-shaped buttocks. English made room for that."
            ),
            VocabQuestion(
              id: "sonder",
              prompt: "sonder",
              detail: "Pick the closest meaning.",
              difficulty: .medium,
              flavor: .fun,
              choices: [
                VocabChoice(id: "a", text: "Realizing strangers have rich inner lives"),
                VocabChoice(id: "b", text: "Sorting objects by color"),
                VocabChoice(id: "c", text: "Leaving a party unnoticed"),
                VocabChoice(id: "d", text: "Hearing music in static")
              ],
              correctChoiceID: "a",
              explanation: "Sonder is a newer coined word for realizing each passerby has a life as vivid as your own."
            )
          ]
        ),
        DailyGame(
          id: DailyGameKind.wordInTheWild.scoreKey,
          title: "Word in the Wild",
          subtitle: "Use context to find the meaning.",
          kind: .wordInTheWild,
          scoring: ScoringRule(maxPoints: 800, completionBonus: 150, perfectBonus: 200),
          questions: [
            VocabQuestion(
              id: "obdurate",
              prompt: "Even after three apologies, he remained obdurate.",
              detail: "What does obdurate imply?",
              difficulty: .medium,
              flavor: .curated,
              choices: [
                VocabChoice(id: "a", text: "Stubbornly unmoved"),
                VocabChoice(id: "b", text: "Quietly delighted"),
                VocabChoice(id: "c", text: "Suddenly confused"),
                VocabChoice(id: "d", text: "Overly generous")
              ],
              correctChoiceID: "a",
              explanation: "Obdurate means stubborn, hardened, or refusing to change."
            ),
            VocabQuestion(
              id: "absquatulate",
              prompt: "When the check arrived, Marco chose to absquatulate.",
              detail: "What did Marco do?",
              difficulty: .hard,
              flavor: .fun,
              choices: [
                VocabChoice(id: "a", text: "Leave abruptly"),
                VocabChoice(id: "b", text: "Order dessert"),
                VocabChoice(id: "c", text: "Pay for everyone"),
                VocabChoice(id: "d", text: "Explain the joke")
              ],
              correctChoiceID: "a",
              explanation: "Absquatulate is a playful word meaning to depart quickly or sneak away."
            )
          ]
        ),
        DailyGame(
          id: DailyGameKind.oddOneOut.scoreKey,
          title: "Odd One Out",
          subtitle: "Spot the word that breaks the set.",
          kind: .oddOneOut,
          scoring: ScoringRule(maxPoints: 600, completionBonus: 100, perfectBonus: 150),
          questions: [
            VocabQuestion(
              id: "talk-set",
              prompt: "Which word does not mean talkative?",
              detail: "Choose the odd one out.",
              difficulty: .medium,
              flavor: .curated,
              choices: [
                VocabChoice(id: "a", text: "Loquacious"),
                VocabChoice(id: "b", text: "Voluble"),
                VocabChoice(id: "c", text: "Taciturn"),
                VocabChoice(id: "d", text: "Chatty")
              ],
              correctChoiceID: "c",
              explanation: "Taciturn means reserved or not inclined to talk."
            ),
            VocabQuestion(
              id: "fake-formal-set",
              prompt: "Which one is not an actual word?",
              detail: "Choose the impostor.",
              difficulty: .easy,
              flavor: .fun,
              choices: [
                VocabChoice(id: "a", text: "Flummox"),
                VocabChoice(id: "b", text: "Borborygmus"),
                VocabChoice(id: "c", text: "Splendacious"),
                VocabChoice(id: "d", text: "Persnickety")
              ],
              correctChoiceID: "c",
              explanation: "Splendacious sounds official, but it is the fake. Borborygmus is the rumbling sound from your stomach."
            )
          ]
        )
      ]
    )
  ]
}
