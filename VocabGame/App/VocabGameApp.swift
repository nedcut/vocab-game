import SwiftUI

@main
struct VocabGameApp: App {
  @State private var store = AppStore()

  var body: some Scene {
    WindowGroup {
      AppView()
        .environment(store)
    }
  }
}
