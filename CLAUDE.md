# Tend: project notes for Claude

Owner: Sergej, a product owner, not a developer. He specifies, you build. Follow his global rules (plan first for big things, small steps, test before saying it works, commit after each working step, ask before spending money or publishing). Reply in the language he writes in.

## What this is

A portfolio demo showing he builds habitually with Claude Code. One native iOS app for plant watering and car reminders (STK inspection, insurance, tyre swap, oil service). Local data only, local notifications. Target: his iPhone 17, iOS 27.2. Minimum deployment iOS 26.

Honest dating: started November 2026. Never present it as older. Public repo only with made-up sample data, nothing personal. Do not claim real users or that he writes the Swift himself.

## Plan (approved)

0. Mockups (done, direction A chosen).
1. Skeleton with sample data: DONE. Today screen, SwiftData models, due-date logic.
2. Add and edit items, item detail, history: DONE. Plant types, car presets, three schedule types (interval, yearly, by km), calendar tab, "My things" grouping, warm copy pass. 107 tests.
3. Local notifications with Done and Snooze actions: DONE. One reminder per item on the due day at 10:30 by default, no repeats. `ReminderPlanner` (tested) decides what to schedule, `ReminderCenter` talks to the system, `NotificationActionHandler` answers the buttons. Oil service: Done opens the odometer sheet. 118 tests. Debug only: launch with `-testReminder Basil` to get a test reminder in 10 seconds.
3b. Safety net (ADHD-friendly, based on his research): DONE. `CareUndo` (Done, Snooze and Fresh start can be undone, bar has no timer), `FreshStart` (spreads overdue plants, max 2 a day, cars never moved), `WelcomeBack` (after 3+ days away). 137 tests. Debug only: launch with `-pileUp YES` for a pile of overdue plants, `-lastActive 1700000000` to fake a long absence.
3c. Calm notifications: DONE. `ReminderSettings` (+ `ReminderSettingsStore` in UserDefaults), digest by default (`ReminderPlanner.digestBody`, 3 mornings ahead so it goes quiet if the app is not opened), per-item style as an option, quiet days, permission card only after first success (`firstSuccess` flag), snooze check-in after 3 in a row (`CareItem.snoozeStreak`), "How Tend talks to you" sheet. Notification tap lands on Today. 166 tests. Debug only: `-digestInMinutes 2` moves the morning note to 2 minutes from launch.
3d. Car routine care and more plant types: DONE. Car presets grouped (Deadlines, Servicing, Routine care, Your own) via `CarTaskGroup`; routine items (`CareItem.isRoutine`: wash, clean interior, tyre pressure) never show as overdue and appear in the morning note only on their own day; new calendar group Cleaning (colour Mist). Tyre pressure hint mentions MyMazda, but there is no integration: no public API found, iOS cannot read another app's data, and unofficial access would mean handing over the Mazda login. New plant types: dracaena 10 days, dipladenia 7 (summer 3 to 4, winter 14 to 21; no automatic seasons yet), campanula 5, camellia 7, strelitzia 10. 182 tests.
3e. Next rounds, each committed separately: playful layer with "Start here" (mood, sprout mascot, springy motion), then icon, then widget. Support tool, not treatment: no diagnostic or efficacy claims, no analytics.
4. Polish: app icon, empty states, maybe a home-screen widget.
5. Run on his real iPhone, README screenshots, short screen recording, public repo.

Limits he knows: free Apple signing expires the on-device app every 7 days (paid program is about 100 USD a year; ask before spending). Recruiters cannot install it. No AI in v1.

## Product decisions (direction A, "Garden notebook")

- Today sections: Overdue, Today, Coming up (next 30 days).
- Mark done = tap the circle (44 pt tap area) or swipe right. Snooze = swipe left, fixed one day.
- Next due counts from the day it was marked done, not from the old due date.
- Each item repeats on a fixed interval and reminds at one time of day (default 10:30). One reminder on the due day, no repeats, no nagging. Permission is asked from a card on Today, not at launch.
- History keeps both Done and Snoozed entries.
- One accent colour (moss green). Terracotta for overdue, always with the word "overdue". Plants and car tasks differ by icon shape (leaf, car), not colour.
- Exception, the Calendar tab only: five muted category colours (Sage, Dusk, Heather, Honey, Stone), each paired with its own icon (`CareCategory`). Never bright, never the only clue.
- Voice: friendly and warm, short sentences, plain words ("Good morning", "Waiting for you", "Let's add your first thing"). Never scolding. Overdue still says "overdue".
- Tabs: Today, Calendar, My things (plants first, then each car, soonest due first), Journal (was History).
- Calendar: short month grid, summary under it (overdue / today / next 7 days), agenda for the picked day. Future entries are projections assuming each task is done on its due day; an overdue task projects from today. At accessibility text sizes the grid becomes a list of days.
- Screen titles in serif (New York) built on text styles; everything else uses system text styles so Dynamic Type works. At accessibility text sizes the row icon is hidden.
- Empty states use `ContentUnavailableView`.
- Signature detail on Today: the circle fills with a tick for a moment, then the row leaves.

## Code rules

- Skills in this folder and in `~/.claude/skills`: `swiftui-pro` (follow it) and `swiftui-design-skill`. Re-read `swiftui-pro` before reviewing.
- One type per Swift file. Views extracted into their own structs, not computed `some View` properties. Button actions in methods.
- Shared sizes and colours live in `Tend/Design/Theme.swift`. Colours are asset-catalog colour sets with light and dark values.
- The module defaults to main-actor isolation. Plain value types used by SwiftData models are marked `nonisolated`.
- Logic first, with a failing test (Swift Testing, `TendTests/`). Use a fixed calendar and dates in tests.
- Debug builds seed sample data on first run (`SampleData.swift`, `#if DEBUG`).
- Do not add third-party packages without asking.

## Build and test from the command line

```bash
xcodebuild test -project Tend.xcodeproj -scheme Tend -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath build CODE_SIGNING_ALLOWED=NO
```

Install and screenshot without the simulator tool: `xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/Tend.app`, then `xcrun simctl launch booted dev.serdz0.Tend`, then `xcrun simctl io booted screenshot <file>.png`. `xcrun simctl ui booted appearance dark` and `content_size accessibility-extra-large` check dark mode and big text. The test run shuts the simulator down; boot it again afterwards.

## Before publishing

- The first commit in this repo (99ab480) was made with his real email. Rewrite it to the GitHub no-reply address (355532830+serdz0@users.noreply.github.com) before any push. The local git config already uses the no-reply address.
- Ask before creating the public GitHub repo. Pick a descriptive repo name (the folder is still called `swiftui-app`).
