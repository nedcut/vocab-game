import SwiftUI

enum AppTheme {
  static let background = Color(.systemGroupedBackground)
  static let panel = Color(.secondarySystemGroupedBackground)
  static let ink = Color(.label)
  static let quietInk = Color(.secondaryLabel)
  static let mint = Color(red: 0.10, green: 0.55, blue: 0.44)
  static let coral = Color(red: 0.84, green: 0.25, blue: 0.23)
  static let gold = Color(red: 0.89, green: 0.64, blue: 0.12)
  static let blue = Color(red: 0.16, green: 0.37, blue: 0.82)

  static func accent(for index: Int) -> Color {
    [mint, coral, gold, blue][index % 4]
  }
}

struct PanelModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .padding(16)
      .background(AppTheme.panel, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
  }
}

extension View {
  func panel() -> some View {
    modifier(PanelModifier())
  }
}
