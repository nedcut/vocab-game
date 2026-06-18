import SwiftUI

struct AvatarView: View {
  let player: Player
  let size: CGFloat

  private var color: Color {
    switch player.colorName {
    case "coral": AppTheme.coral
    case "gold": AppTheme.gold
    case "blue": AppTheme.blue
    default: AppTheme.mint
    }
  }

  var body: some View {
    Text(player.initials)
      .font(.system(size: size * 0.34, weight: .bold, design: .rounded))
      .foregroundStyle(.white)
      .frame(width: size, height: size)
      .background(color, in: Circle())
      .accessibilityLabel(player.displayName)
  }
}
