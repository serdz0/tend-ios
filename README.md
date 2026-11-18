# Tend

A small iPhone app that reminds me when to water the plants and when the car needs something: STK inspection, insurance, tyre swap, oil service. Everything stays on the phone. No account, no server.

> Built with Claude Code from my requirements; I specify and review, I do not write the Swift by hand. Started November 2026. Sample data and made-up names only.

## What works now (Step 1)

- **Today** screen: overdue items first, then due today, then coming up in the next 30 days.
- Tap the circle to mark an item done. Swipe right to mark done, swipe left to snooze one day.
- Next due date counts from the day you mark it done, so a plant watered late is not due again tomorrow.
- Light and dark mode. Works at the largest text size.
- Seven made-up sample items load on the first run of a debug build.

Not built yet: adding and editing items, reminders as notifications, history, app icon.

## Run it

Needs Xcode 27 and the iOS 27 simulator.

```bash
xcodebuild test -project Tend.xcodeproj -scheme Tend -destination 'platform=iOS Simulator,name=iPhone 17' CODE_SIGNING_ALLOWED=NO
```

Or open `Tend.xcodeproj` in Xcode and press Run.

## Tech

SwiftUI, SwiftData (local storage), Swift Testing. Minimum iOS 26. iPhone only. No third-party packages.

## Look

Direction "Garden notebook": warm paper background, moss green for actions, terracotta for overdue, serif screen titles. Plants and car tasks are told apart by icon shape, and overdue is always written in words, never colour alone.

## Skills used

[`swiftui-pro`](https://github.com/twostraws/SwiftUI-Agent-Skill) (code review rules, MIT, by Paul Hudson), installed in `.claude/skills/swiftui-pro/` (recorded in `skills-lock.json`), plus a SwiftUI design skill for the look.

## Next

2. Add and edit items (plants and car presets), history, item detail.
3. Local notifications with Done and Snooze buttons.
4. Polish: icon, empty states, maybe a home-screen widget.
5. Run on a real iPhone, screenshots, short screen recording.
