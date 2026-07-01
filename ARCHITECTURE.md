# WorkTrace Architecture

## Pipeline Hierarchy

WorkTrace compresses activity through a fixed hierarchy:

Sample -> Activity Block -> Session -> Mission -> Timeline -> Story -> Pattern -> Memory -> Reflection

Each layer contains less raw data and more meaning than the previous layer.

## Layer Responsibilities

- Sample: a lightweight frontmost-app observation.
- Activity Block: continuous work inside one application.
- Session: a deterministic work period made from nearby Activity Blocks.
- Mission: the first semantic layer above Session, grouping related Sessions separated by short gaps.
- Timeline: a chronological representation of today's Missions.
- Story: a daily work narrative built from Missions.
- Pattern: deterministic repeated structures discovered from compressed work history.
- Memory: deterministic structured facts built from compressed layers.
- Reflection: future optional AI analysis over compressed data only.

## Detector Responsibilities

- `SessionDetector` converts Activity Blocks into Sessions.
- `MissionDetector` converts Sessions into Missions.
- Detectors are pure transformation layers.
- Detectors do not know about SwiftUI.
- Detectors do not perform storage.
- Detectors do not read content.
- Detectors do not call AI or network services.

## Generator Responsibilities

- `StoryGenerator` converts Missions into one daily Story.
- `StoryGenerator` is deterministic and local-only.
- `StoryGenerator` does not know about SwiftUI.
- `StoryGenerator` does not perform storage.
- `StoryGenerator` does not read content.
- `StoryGenerator` does not call AI or network services.

## Timeline Responsibilities

- `TimelineBuilder` converts existing Missions into today's chronological Timeline.
- `TimelineBuilder` consumes Missions only.
- `TimelineBuilder` does not call `MissionDetector`.
- `TimelineBuilder` does not read raw Samples.
- `TimelineBuilder` does not perform storage.
- `TimelineBuilder` does not know about SwiftUI.
- Timeline is computed state only.

## Pattern Responsibilities

- `PatternEngine` discovers deterministic Patterns from Stories, Missions, or Sessions.
- `PatternEngine` may analyze compressed Stories, Missions, and Sessions.
- `PatternEngine` must not call AI.
- `PatternEngine` must not generate natural language.
- `PatternEngine` must not judge productivity.
- `PatternEngine` must not classify activities.
- `PatternEngine` must not infer emotions or intent.
- `PatternEngine` must not make predictions.
- `PatternEngine` must not perform storage or know about SwiftUI.
- Phase 6 only implements Repeated App Sequence.

## Memory Responsibilities

- `MemoryBuilder` builds one local MemoryBook for today.
- `MemoryBuilder` consumes Story, Timeline, Patterns, and Missions only.
- `MemoryBuilder` does not know about SwiftUI.
- `MemoryBuilder` does not perform storage.
- `MemoryBuilder` does not call AI.
- `MemoryBuilder` does not read raw Samples.
- `MemoryBuilder` does not generate advice or judge productivity.

## Why Mission Exists

Mission is the first semantic layer above Session. Sessions may be too small to describe a meaningful work arc. Mission groups nearby Sessions into a larger unit that can later support local Story generation and optional AI Reflection without exposing raw Samples.

## Layering Rules

- Tracking records Samples only.
- Storage persists local Samples and handles retention.
- Compression transforms data between pipeline layers.
- `CompressionEngine` coordinates the pipeline and delegates Story generation to `StoryGenerator`.
- `TimelineBuilder` runs after Mission detection and before Story display.
- `PatternEngine` runs after Story/Mission compression and discovers repeatable facts only.
- `MemoryBuilder` runs after Story, Timeline, and Pattern generation and creates structured facts only.
- Views display already-computed state.
- Views may use display-only formatting helpers for safe durations, confidence values, and empty states.
- Raw Samples are never prepared for AI.
- Future AI consumes MemoryBook, Pattern, Story, Timeline, Mission, or higher-level compressed data only.

## MemoryBook Presentation

Phase 9 adds MemoryBook as a product-facing presentation layer. It does not change the compression pipeline.

- `Views/MemoryBook/MemoryBookView.swift` composes today's compressed work into a notebook-style view.
- MemoryBook presentation consumes existing computed state: `MemoryBook`, `Story`, `Timeline`, `Pattern`, and `Mission`.
- MemoryBook presentation performs no detection, compression, storage, persistence, networking, or AI calls.
- MemoryBook is not Reflection.
- MemoryBook is not persisted.
- MemoryBook exists to make compressed work history feel like a local work notebook rather than an analytics dashboard.
- Dashboard growth should pause at this stage; future work should improve product value rather than add more dashboard sections.

## Dashboard Presentation

Phase 9 keeps the dashboard feature-complete for this stage and embeds MemoryBook as the primary product-facing view.

- `DashboardView` owns the app shell, compact controls, Today Summary, MemoryBook presentation, Diagnostics, and Data Status.
- MemoryBook is the primary daily output.
- Diagnostics remain available and expanded by default, but visually quieter than primary sections.
- Data Status appears lower as a privacy/footer section.
- `Views/Components/DashboardComponents.swift` contains display-only helpers for section cards, status pills, icon buttons, and disclosure sections.
- Dashboard components must not perform compression, tracking, storage, pattern detection, memory building, story generation, or timeline building.
- The header uses compact macOS-style controls and does not create floating windows.

## Memory Engine

Phase 8 adds the deterministic Memory layer before future Reflection.

- Memory is not AI.
- MemoryBook is computed state only and is not persisted yet.
- MemoryItems are typed deterministic facts.
- Initial MemoryItem types are daily summary, dominant app, long Mission, repeated Pattern, and Timeline shape.
- Memory exists so future AI receives compact structured facts instead of raw Samples.
- Future AI must never consume raw Samples.

## Timeline Engine

Phase 7 adds the computed Timeline layer.

- Timeline is generated from existing Missions only.
- Timeline items contain start time, end time, duration, dominant app, Mission title, and Mission id.
- Timeline items are sorted chronologically.
- Overlapping Missions are protected by clamping each item start to the previous item end.
- Timeline is not persisted and does not duplicate storage.
- The Today Timeline dashboard section displays Timeline items but does not build them.

## Story Generation

Phase 5 adds deterministic local Story generation.

- Stories are generated from Missions only.
- Empty Missions produce a safe empty Story.
- Story summaries and highlights are rule-based observations, not AI output.
- Story highlights currently include longest Mission duration, dominant app, total Sessions, and total Missions.
- The Story dashboard section displays the generated Story but does not create or transform it.

## Pattern Engine

Phase 6 adds the deterministic Pattern layer before future Reflection.

- Patterns are generated from compressed Stories, Missions, or Sessions.
- The first Pattern type is Repeated App Sequence.
- A Pattern stores sequence, frequency, average start time, average duration, confidence, and last seen.
- Pattern discovery does not interpret, predict, score, classify, or label behavior.
- The Pattern dashboard section displays counts and timestamps only; it does not perform Pattern detection.

## Dashboard Stability

Phase 4.1 focused on dashboard scrollability, layout stability, and defensive UI formatting.

- The dashboard is vertically scrollable so Mission Summary, Compression, Top Apps, Timeline, and Data Status remain reachable in smaller windows.
- Dashboard sections should prefer compact, readable layouts over dense single-row presentations.
- Empty Samples, Activity Blocks, Sessions, Missions, or Stories must render placeholder text rather than unsafe values.
- Durations and confidence values are formatted for display only; detectors and compression models remain responsible for data semantics.

## Privacy Boundary

WorkTrace remains local-first:

- No AI in the current implementation.
- No networking.
- No notifications or reminders.
- No clipboard reading.
- No screenshots.
- No browser history.
- No file content reading.
