# WorkTrace

A local-first macOS work memory application.

WorkTrace quietly observes which application is in the foreground and transforms simple activity into meaningful work memories — Sessions, Missions, Stories, Patterns, and Memory.

Everything runs locally.

No AI.
No cloud.
No screenshots.
No clipboard.
No browser history.

---

## Why WorkTrace?

Most productivity tools ask people to manually write notes or track time.

WorkTrace takes a different approach.

Instead of recording content, it only records application transitions and timestamps, then reconstructs your workday into higher-level structures.

The goal is simple:

> Help you remember **how you worked**, not **what you wrote**.

---

## Features

Current Version (v1)

- Local-only activity tracking
- Session detection
- Mission detection
- Daily Story generation
- Timeline visualization
- Pattern engine (foundation)
- Memory abstraction
- Top applications summary
- Privacy-first architecture
- Native SwiftUI macOS interface

---

## Architecture

```
Raw Events
      │
      ▼
Activity Blocks
      │
      ▼
Sessions
      │
      ▼
Missions
      │
      ▼
Timeline
      │
      ▼
Story
      │
      ▼
Patterns
      │
      ▼
Memory
```

Every layer is deterministic and fully local.

---

## Privacy

WorkTrace intentionally **does not** collect:

- screenshots
- clipboard
- browser history
- file contents
- keyboard input
- microphone
- AI prompts
- cloud data

Only timestamps and foreground application names are processed.

---

## Tech Stack

- Swift
- SwiftUI
- macOS
- MVVM Architecture

---

## Roadmap

### Version 1
- ✅ Local tracking
- ✅ Sessions
- ✅ Missions
- ✅ Stories
- ✅ Patterns
- ✅ Memory

### Version 2
- AI Memory Assistant
- Natural language daily summaries
- Weekly review
- Searchable memories

### Version 3
- Personal work intelligence
- Long-term behavior learning
- Context-aware recommendations

---

## Status

Currently under active development.

This repository represents the first public version of WorkTrace.
