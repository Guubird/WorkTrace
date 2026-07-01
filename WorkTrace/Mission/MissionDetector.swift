import Foundation

enum MissionDetector {
    static let defaultIdleThreshold: TimeInterval = 15 * 60

    static func detectMissions(
        from sessions: [Session],
        idleThreshold: TimeInterval = defaultIdleThreshold
    ) -> [Mission] {
        let sortedSessions = sessions.sorted { $0.startTime < $1.startTime }
        guard let firstSession = sortedSessions.first else {
            return []
        }

        var missions: [Mission] = []
        var currentSessions: [Session] = [firstSession]

        for session in sortedSessions.dropFirst() {
            guard let previousSession = currentSessions.last else {
                currentSessions = [session]
                continue
            }

            let gap = session.startTime.timeIntervalSince(previousSession.endTime)
            if gap < idleThreshold {
                currentSessions.append(session)
            } else {
                missions.append(makeMission(from: currentSessions))
                currentSessions = [session]
            }
        }

        missions.append(makeMission(from: currentSessions))
        return missions
    }

    // MARK: Future Mission Semantics

    // Later versions can group Sessions by user-visible intent without reading content.

    // MARK: Future Mission Naming

    // Mission naming is intentionally not implemented in Phase 4.

    // MARK: Future AI-Assisted Mission Reflection

    // Future AI may consume Missions and Stories, never raw Samples.

    private static func makeMission(from sessions: [Session]) -> Mission {
        let sortedSessions = sessions.sorted { $0.startTime < $1.startTime }
        guard let firstSession = sortedSessions.first, let lastSession = sortedSessions.last else {
            return Mission(
                startTime: Date(),
                endTime: Date(),
                sessions: []
            )
        }

        return Mission(
            startTime: firstSession.startTime,
            endTime: lastSession.endTime,
            sessions: sortedSessions
        )
    }
}
