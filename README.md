# Vocab Game

An iPhone-first SwiftUI prototype for private daily word games with friend-group competition.

## Current Prototype

- Three daily multiple-choice word games.
- Local mock data for multiple groups, friends, scores, and weekly totals.
- Spoiler-safe daily leaderboards: friend scores are hidden until you finish that game.
- Weekly leaderboards for each game and aggregate totals.
- Placeholder profile surface for Apple Sign In, Supabase-backed accounts, invites, and notifications.

## Tooling

The Xcode project is generated with XcodeGen:

```sh
xcodegen generate
```

Build the app for the iOS Simulator SDK:

```sh
xcodebuild -project VocabGame.xcodeproj -scheme VocabGame -sdk iphonesimulator -derivedDataPath DerivedData build
```

Compile the XCTest bundle:

```sh
xcodebuild -project VocabGame.xcodeproj -target VocabGameTests -sdk iphonesimulator build
```

`xcodebuild test` currently hits local destination discovery issues in this environment, but the app target and test bundle both compile.
