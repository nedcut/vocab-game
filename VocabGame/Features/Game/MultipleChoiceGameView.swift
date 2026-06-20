import SwiftUI

struct MultipleChoiceGameView: View {
  @Environment(AppStore.self) private var store
  @Environment(\.dismiss) private var dismiss

  let game: DailyGame

  @State private var currentIndex = 0
  @State private var selectedChoiceID: String?
  @State private var answers: [String: String] = [:]
  @State private var didFinish = false

  private var currentQuestion: VocabQuestion {
    game.questions[currentIndex]
  }

  private var correctCount: Int {
    game.questions.reduce(0) { count, question in
      answers[question.id] == question.correctChoiceID ? count + 1 : count
    }
  }

  var body: some View {
    VStack(spacing: 0) {
      if didFinish || store.completion(for: game) != nil {
        completionView
      } else {
        questionView
      }
    }
    .background(AppTheme.background)
    .navigationTitle(game.title)
    .navigationBarTitleDisplayMode(.inline)
  }

  private var questionView: some View {
    VStack(alignment: .leading, spacing: 18) {
      progressHeader

      VStack(alignment: .leading, spacing: 10) {
        Text(currentQuestion.prompt)
          .font(.title.weight(.bold))
          .fixedSize(horizontal: false, vertical: true)
        Text(currentQuestion.detail)
          .font(.subheadline)
          .foregroundStyle(AppTheme.quietInk)
      }
      .panel()

      VStack(spacing: 10) {
        ForEach(currentQuestion.choices) { choice in
          ChoiceButton(
            choice: choice,
            correctChoiceID: currentQuestion.correctChoiceID,
            selectedChoiceID: selectedChoiceID
          ) {
            guard selectedChoiceID == nil else { return }
            selectedChoiceID = choice.id
            answers[currentQuestion.id] = choice.id
          }
        }
      }

      if selectedChoiceID != nil {
        explanation
      }

      Spacer(minLength: 12)

      Button {
        advance()
      } label: {
        Label(currentIndex == game.questions.count - 1 ? "Finish" : "Next", systemImage: "arrow.right.circle.fill")
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
      .disabled(selectedChoiceID == nil)
    }
    .padding(20)
  }

  private var progressHeader: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text("Round \(currentIndex + 1) of \(game.questions.count)")
          .font(.subheadline.weight(.semibold))
        Spacer()
        Text("\(correctCount) correct")
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(AppTheme.quietInk)
      }

      ProgressView(value: Double(currentIndex), total: Double(game.questions.count))
        .tint(AppTheme.mint)
    }
  }

  private var explanation: some View {
    let isCorrect = selectedChoiceID == currentQuestion.correctChoiceID

    return VStack(alignment: .leading, spacing: 6) {
      Label(isCorrect ? "Got it" : "Not quite", systemImage: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
        .font(.headline)
        .foregroundStyle(isCorrect ? AppTheme.mint : AppTheme.coral)
      Text(currentQuestion.explanation)
        .font(.subheadline)
        .foregroundStyle(AppTheme.quietInk)
        .fixedSize(horizontal: false, vertical: true)
    }
    .panel()
  }

  private var completionView: some View {
    let completion = store.completion(for: game)
    let finalCorrect = completion?.correct ?? correctCount
    let finalScore = completion?.score ?? game.scoring.score(correct: finalCorrect, total: game.questions.count)

    return ScrollView {
      VStack(alignment: .leading, spacing: 18) {
        VStack(alignment: .leading, spacing: 8) {
          Text("Score posted")
            .font(.largeTitle.weight(.bold))
          Text("\(finalScore) points")
            .font(.title2.weight(.semibold))
            .foregroundStyle(AppTheme.mint)
          Text("\(finalCorrect) of \(game.questions.count) correct. The leaderboard is unlocked for \(store.selectedGroup.name).")
            .font(.subheadline)
            .foregroundStyle(AppTheme.quietInk)
        }
        .panel()

        ShareLink(item: resultShareText(score: finalScore, correct: finalCorrect)) {
          Label("Share result", systemImage: "square.and.arrow.up")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)

        LeaderboardList(
          title: "Today",
          rows: store.dailyLeaderboard(for: game),
          hidesScoresUntilPlayed: false
        )

        Button {
          dismiss()
        } label: {
          Label("Back to today", systemImage: "sun.max.fill")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
      }
      .padding(20)
    }
  }

  private func advance() {
    if currentIndex == game.questions.count - 1 {
      store.complete(game: game, correct: correctCount, total: game.questions.count)
      didFinish = true
      return
    }

    currentIndex += 1
    selectedChoiceID = answers[currentQuestion.id]
  }

  private func resultShareText(score: Int, correct: Int) -> String {
    "\(game.title): \(score) points, \(correct)/\(game.questions.count) correct in \(store.selectedGroup.name)."
  }
}

private struct ChoiceButton: View {
  let choice: VocabChoice
  let correctChoiceID: String
  let selectedChoiceID: String?
  let action: () -> Void

  private var isSelected: Bool {
    selectedChoiceID == choice.id
  }

  private var isCorrectChoice: Bool {
    choice.id == correctChoiceID
  }

  private var borderColor: Color {
    guard selectedChoiceID != nil else { return Color(.separator) }
    if isCorrectChoice { return AppTheme.mint }
    if isSelected { return AppTheme.coral }
    return Color(.separator)
  }

  var body: some View {
    Button(action: action) {
      HStack(spacing: 12) {
        Text(choice.text)
          .font(.body.weight(.semibold))
          .multilineTextAlignment(.leading)
          .foregroundStyle(AppTheme.ink)
        Spacer()
        if selectedChoiceID != nil {
          Image(systemName: isCorrectChoice ? "checkmark.circle.fill" : (isSelected ? "xmark.circle.fill" : "circle"))
            .foregroundStyle(isCorrectChoice ? AppTheme.mint : (isSelected ? AppTheme.coral : AppTheme.quietInk))
            .accessibilityHidden(true)
        }
      }
      .padding(14)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(AppTheme.panel, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .stroke(borderColor, lineWidth: selectedChoiceID == nil ? 1 : 2)
      }
    }
    .buttonStyle(.plain)
  }
}
