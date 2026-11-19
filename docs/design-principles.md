# Design principles: ADHD-friendly choices and how much evidence is behind them

Tend is a support tool for remembering plant and car care. It is not a treatment and makes no medical claims. This file lists each ADHD-related choice and how strong the reason for it is.

Labels:
- **Standard**: an accessibility or usability guideline (W3C COGA, WCAG 2.2, Apple Human Interface Guidelines).
- **Qualitative**: reported by people with ADHD in studies and reviews, but not tested in controlled trials.
- **Inference**: my reasoning from the above. Treat as a hypothesis.

| Choice | Why | Evidence |
| --- | --- | --- |
| Undo for Done and Snooze, with no timer | Easy recovery from mistakes; a timed undo penalises slow reactions | Standard |
| "Fresh start" spreads overdue plants, two a day | Lapses are normal; a pile of overdue items can make people avoid the app | Qualitative |
| Car deadlines are never moved by Fresh start | Real-world deadlines (inspection, insurance) should not be silently pushed | Inference |
| Welcome back after 3+ days, neutral tone, one small first step | Shame after a gap causes abandonment; one concrete step lowers the cost of restarting | Qualitative |
| Nothing is scolding; overdue is a terracotta word, not an alarm | Avoid punishment-style design | Qualitative |
| One morning note by default, per-item reminders optional | Batched, user-controlled notifications; many separate pings are a common reason people turn notifications off | Qualitative |
| Notes only look 3 days ahead, so they stop if the app is not opened | No evidence that escalating reminders help; backing off respects attention | Inference |
| Wording rotates between a few warm variants | Novelty fades with repetition | Inference |
| Quiet days (rest of today, 3 days, a week) | User control over interruptions | Standard |
| Permission is asked only after the first thing is added or finished | Minimal setup, first value before configuration | Qualitative |
| Check-in after 3 snoozes in a row, in the app, with "Don't ask again" | Repeated postponing may mean the schedule does not fit; no evidence on effect, so it can be switched off | Inference |
| Tap targets at least 44 pt, text scales, colour never the only clue | Accessibility floor | Standard |

Not done on purpose: streaks that break, escalating reminders, analytics, any claim about outcomes.
