import SwiftUI

struct TodayView: View {
  @Environment(AppStore.self) private var store

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 18) {
        header

        ForEach(Array(store.today.games.enumerated()), id: \.element.id) { index, game in
          NavigationLink {
            MultipleChoiceGameView(game: game)
          } label: {
            DailyGameCard(
              game: game,
              completion: store.completion(for: game),
              accent: AppTheme.accent(for: index)
            )
          }
          .buttonStyle(.plain)
        }

        dailyGroupPreview
      }
      .padding(20)
    }
    .background(AppTheme.background)
    .navigationTitle("Today")
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Daily words")
        .font(.largeTitle.weight(.bold))
      Text("Everyone in \(store.selectedGroup.name) gets the same set. Scores stay hidden until you finish each game.")
        .font(.subheadline)
        .foregroundStyle(AppTheme.quietInk)
        .fixedSize(horizontal: false, vertical: true)
    }
  }

  private var dailyGroupPreview: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("Group pulse")
          .font(.headline)
        Spacer()
        NavigationLink("All leaders") {
          LeaderboardsView()
        }
        .font(.subheadline.weight(.semibold))
      }

      HStack(spacing: 10) {
        ForEach(store.selectedGroup.members) { member in
          VStack(spacing: 6) {
            AvatarView(player: member, size: 42)
            Text(member.displayName)
              .font(.caption)
              .lineLimit(1)
          }
          .frame(maxWidth: .infinity)
        }
      }
    }
    .panel()
  }
}

private struct DailyGameCard: View {
  let game: DailyGame
  let completion: GameCompletion?
  let accent: Color

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 6) {
          Text(game.title)
            .font(.title3.weight(.bold))
            .foregroundStyle(AppTheme.ink)
          Text(game.subtitle)
            .font(.subheadline)
            .foregroundStyle(AppTheme.quietInk)
        }

        Spacer()

        Image(systemName: completion == nil ? "play.fill" : "checkmark.circle.fill")
          .font(.title3)
          .foregroundStyle(accent)
          .accessibilityHidden(true)
      }

      HStack(spacing: 10) {
        Label("\(game.questions.count) rounds", systemImage: "list.number")
        Label("\(game.scoring.maxPoints + game.scoring.completionBonus + game.scoring.perfectBonus) max", systemImage: "star.fill")
      }
      .font(.caption.weight(.semibold))
      .foregroundStyle(AppTheme.quietInk)

      if let completion {
        ScorePill(text: "\(completion.score) pts", color: accent)
      } else {
        ScorePill(text: "Unplayed", color: accent.opacity(0.75))
      }
    }
    .panel()
  }
}

private struct ScorePill: View {
  let text: String
  let color: Color

  var body: some View {
    Text(text)
      .font(.caption.weight(.bold))
      .padding(.horizontal, 10)
      .padding(.vertical, 6)
      .foregroundStyle(.white)
      .background(color, in: Capsule())
  }
}
