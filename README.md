# Tend

A small iPhone app that reminds me when to water the plants and when the car needs something: STK inspection, insurance, tyre swap, oil service. Everything stays on the phone. No account, no server.

> Built with Claude Code from my requirements; I specify and review, I do not write the Swift by hand. Started November 2026. Sample data and made-up names only.

## What works now (Steps 1 to 3, plus the safety net)

- **Today**: a greeting, one warm sentence about what is waiting, then "Waiting for you" (overdue), "For today" and "Coming up" (next 30 days).
- Tap the circle to mark an item done. Swipe right to mark done, swipe left to snooze one day.
- **Calendar**: a short month grid with soft coloured dots, a summary of what needs doing, and the plan for the day you pick. Future dates are projected from each schedule.
- **My things**: plants first, then each car, soonest due first. Add, edit and delete items; plants come with a type that sets the watering interval.
- Car presets: STK every 2 years, insurance yearly, winter tyres by 31 October, summer tyres around 1 April, oil service every 15,000 km (estimated from your odometer readings).
- **Journal**: everything marked done or snoozed, grouped by day.
- Light and dark mode. Works at the largest text size.
- **Reminders**: a notification on the due day at 10:30 (changeable per item), with **Done** and **Snooze for a day** buttons. For oil service, Done opens the app to ask for the odometer. Tend asks permission from a friendly card on Today, not at launch. One reminder per item, no repeats.
- **Undo** for every Done and Snooze: a bar that stays until you tap Undo or close it. No countdown to race.
- **Fresh start**: when 3 or more plants are overdue, one tap spreads them over the next days, two a day (undoable). Car deadlines are never moved.
- **Welcome back**: after 3 or more days away, one calm line about what is waiting and one small place to start. No guilt, no day counts.
- Made-up sample items load on the first run of a debug build.

Not built yet: app icon, widget.

## Run it

Needs Xcode 27 and the iOS 27 simulator.

```bash
xcodebuild test -project Tend.xcodeproj -scheme Tend -destination 'platform=iOS Simulator,name=iPhone 17' CODE_SIGNING_ALLOWED=NO
```

Or open `Tend.xcodeproj` in Xcode and press Run.

## Tech

SwiftUI, SwiftData (local storage), Swift Testing. Minimum iOS 26. iPhone only. No third-party packages.

## Look

Direction "Garden notebook": warm paper background, moss green for actions, terracotta for overdue, serif screen titles. The calendar adds five muted tones (sage, dusk, heather, honey, stone), one per sort of task. Every task type also has its own icon, and overdue is always written in words, so colour is never the only clue.

Voice: friendly and warm, short sentences, no nagging. "Good morning", "Waiting for you", "A quiet day. Nothing planned."

## Skills used

[`swiftui-pro`](https://github.com/twostraws/SwiftUI-Agent-Skill) (code review rules, MIT, by Paul Hudson), installed in `.claude/skills/swiftui-pro/` (recorded in `skills-lock.json`), plus a SwiftUI design skill for the look.

## Next

4. Polish: icon, maybe a home-screen widget.
5. Run on a real iPhone, screenshots, short screen recording.
