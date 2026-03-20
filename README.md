# SplatSchedule 🦑

A beautiful, Apple-native macOS app for viewing Splatoon 3 battle schedules — built with SwiftUI.

## Features

- **All Battle Modes** — Turf War, Anarchy Open, Anarchy Series, X Battle
- **Live Data** — Auto-refreshes every 30 minutes from splatoon3.ink
- **Stage Images** — Real stage artwork loaded from SplatNet
- **Countdown Timer** — See exactly how long until the next rotation
- **Expandable Rows** — Tap any upcoming slot to reveal stage maps
- **Apple-native UI** — Sidebar navigation, materials, rounded corners, SF Symbols
- **Dark/Light Mode** — Follows your system appearance

## Planned features

- ~~Salmon Run rotation support (coming when I, or anyone forking this, can fix it)~~ Salmon run support added in v0.2 ✅
- Siri integration (???)
- iOS, iPadOS and watchOS support (coming in the very far future)


## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15 or later

## How to Run

1. Open `SplatSchedule.xcodeproj` in Xcode
2. Select the **SplatSchedule** scheme
3. Press **⌘R** to build and run
4. The app fetches live schedule data on launch — no account needed!

*SplatSchedule.app coming soon!*


## Project Structure

```
SplatSchedule/
├── SplatScheduleApp.swift     # App entry point
├── ContentView.swift          # Root layout (sidebar + main area)
├── Models.swift               # Codable data models
├── ScheduleService.swift      # Network fetching & data parsing
├── SidebarView.swift          # Left navigation panel
└── ModeScheduleView.swift     # Battle mode schedule display
```

## Data Sources

- **Schedules**: `https://splatoon3.ink/data/schedules.json`

Thanks to [splatoon3.ink](https://splatoon3.ink) for the excellent public API!

Not affiliated with Nintendo Co., Ltd. Splatoon™ is a registered trademark of Nintendo. All copyrights belong to their respective owners.
