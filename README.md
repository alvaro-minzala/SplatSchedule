# SplatSchedule 🦑

A beautiful, Apple-native macOS app for viewing Splatoon 3 battle schedules — built with SwiftUI.

## Features

- **All Battle Modes** — Turf War, Anarchy Open, Anarchy Series, X Battle
- **Salmon Run** — Co-op schedules including Big Run & Eggstra Work
- **Live Data** — Auto-refreshes every 30 minutes from splatoon3.ink
- **Stage Images** — Real stage artwork loaded from SplatNet
- **Countdown Timer** — See exactly how long until the next rotation
- **Expandable Rows** — Tap any upcoming slot to reveal stage maps
- **Apple-native UI** — Sidebar navigation, materials, rounded corners, SF Symbols
- **Dark/Light Mode** — Follows your system appearance

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15 or later

## How to Run

1. Open `SplatSchedule.xcodeproj` in Xcode
2. Select the **SplatSchedule** scheme
3. Press **⌘R** to build and run
4. The app fetches live schedule data on launch — no account needed!

## Notes on Salmon Run

The public `coop.json` endpoint from splatoon3.ink returns personal player data
(grades, scores, history) rather than public schedule data. If Salmon Run shows
no rotations, that's expected — the schedule data for Salmon Run requires
an authenticated SplatNet 3 session via the Nintendo Switch Online app.

For Salmon Run schedules, we recommend visiting [splatoon3.ink](https://splatoon3.ink)
directly, or using the [s3s](https://github.com/frozenpandaman/s3s) tool for
authenticated API access.

## Project Structure

```
SplatSchedule/
├── SplatScheduleApp.swift     # App entry point
├── ContentView.swift          # Root layout (sidebar + main area)
├── Models.swift               # Codable data models
├── ScheduleService.swift      # Network fetching & data parsing
├── SidebarView.swift          # Left navigation panel
├── ModeScheduleView.swift     # Battle mode schedule display
└── SalmonRunView.swift        # Salmon Run co-op display
```

## Data Sources

- **Schedules**: `https://splatoon3.ink/data/schedules.json`
- **Co-op**: `https://splatoon3.ink/data/coop.json`

Thanks to [splatoon3.ink](https://splatoon3.ink) for the excellent public API!
