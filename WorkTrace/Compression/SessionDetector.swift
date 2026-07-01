import Foundation

enum SessionDetector {
    static let defaultIdleThreshold: TimeInterval = 10 * 60

    static func detectSessions(
        from activityBlocks: [ActivityBlock],
        idleThreshold: TimeInterval = defaultIdleThreshold
    ) -> [Session] {
        let sortedBlocks = activityBlocks.sorted { $0.startTime < $1.startTime }
        guard let firstBlock = sortedBlocks.first else {
            return []
        }

        var sessions: [Session] = []
        var currentBlocks: [ActivityBlock] = [firstBlock]

        for block in sortedBlocks.dropFirst() {
            guard let previousBlock = currentBlocks.last else {
                currentBlocks = [block]
                continue
            }

            let gap = block.startTime.timeIntervalSince(previousBlock.endTime)
            if gap <= idleThreshold {
                currentBlocks.append(block)
            } else {
                sessions.append(makeSession(from: currentBlocks))
                currentBlocks = [block]
            }
        }

        sessions.append(makeSession(from: currentBlocks))
        return sessions
    }

    // MARK: Future Semantic Session Detection

    // Later versions can merge or split Activity Blocks using local-only semantic rules.

    // MARK: Future Session Title Generation

    // Phase 3 keeps deterministic placeholder titles.

    // MARK: Future AI-Assisted Session Labeling

    // Future AI must only label compressed Session and Story data, never raw Samples.

    private static func makeSession(from activityBlocks: [ActivityBlock]) -> Session {
        let sortedBlocks = activityBlocks.sorted { $0.startTime < $1.startTime }
        guard let firstBlock = sortedBlocks.first, let lastBlock = sortedBlocks.last else {
            return Session(
                startTime: Date(),
                endTime: Date(),
                activityBlocks: []
            )
        }

        return Session(
            title: "General Work Session",
            startTime: firstBlock.startTime,
            endTime: lastBlock.endTime,
            activityBlocks: sortedBlocks
        )
    }
}
