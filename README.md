# Vocab Game

An iPhone-first SwiftUI prototype for private daily word games with friend-group competition.

## Current Prototype

- Three daily multiple-choice word games from deterministic date-based content packs.
- Starter content packs mix curated words, fun words, and difficulty tags.
- Local mock data for multiple groups, friends, scores, and weekly totals.
- Persisted local state for selected group, finished games, and reminder settings.
- Spoiler-safe daily leaderboards: friend scores are hidden until you finish that game.
- Daily aggregate leaderboards once all games are complete.
- Weekly leaderboards for each game and aggregate totals.
- Local reminder notification scheduling from the Profile tab.
- Placeholder profile surface for Apple Sign In, Supabase-backed accounts, and invites.

## Tooling

The Xcode project is generated with XcodeGen:

```sh
xcodegen generate
```

Build the app for the iOS Simulator SDK:

```sh
xcodebuild -project VocabGame.xcodeproj -target VocabGame -sdk iphonesimulator build
```

Compile the XCTest bundle:

```sh
xcodebuild -project VocabGame.xcodeproj -target VocabGameTests -sdk iphonesimulator build
```

`xcodebuild test` currently hits local destination discovery issues in this environment, but the app target and test bundle both compile.
