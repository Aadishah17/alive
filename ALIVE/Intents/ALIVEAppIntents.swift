import AppIntents
import Foundation
import SwiftData

/// A fixed, display-friendly destination surface for Siri, Shortcuts, and Spotlight.
/// App tabs remain an implementation detail; this enum exposes only useful verbs.
public enum ALIVEIntentDestination: String, AppEnum, CaseIterable, Sendable {
    case today
    case quests
    case focus
    case academics
    case skills
    case badges

    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "ALIVE destination")
    }

    public static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .today: DisplayRepresentation(title: "Today", image: .init(systemName: "shield.lefthalf.filled")),
            .quests: DisplayRepresentation(title: "Quest board", image: .init(systemName: "scroll.fill")),
            .focus: DisplayRepresentation(title: "Focus session", image: .init(systemName: "timer")),
            .academics: DisplayRepresentation(title: "Academics", image: .init(systemName: "percent")),
            .skills: DisplayRepresentation(title: "Skill tree", image: .init(systemName: "tree.fill")),
            .badges: DisplayRepresentation(title: "Badge vault", image: .init(systemName: "crown.fill"))
        ]
    }

    fileprivate var route: ALIVEIntentRoute {
        switch self {
        case .today:
            return .today
        case .quests:
            return .quests
        case .focus:
            return .focus
        case .academics:
            return .academics
        case .skills:
            return .skills
        case .badges:
            return .badges
        }
    }
}

/// A lightweight, system-facing representation of a persistent quest. It shadows
/// the SwiftData model instead of exposing the full mutable persistence graph.
public struct QuestAppEntity: AppEntity, Sendable {
    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Quest")
    }

    public static var defaultQuery = QuestAppEntityQuery()

    public let id: UUID
    public let title: String
    public let category: String
    public let xpReward: Int

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(category) · +\(xpReward) XP",
            image: .init(systemName: "scroll.fill")
        )
    }

    public init(id: UUID, title: String, category: String, xpReward: Int) {
        self.id = id
        self.title = title
        self.category = category
        self.xpReward = xpReward
    }

    init(quest: Quest) {
        self.init(
            id: quest.id,
            title: quest.title,
            category: quest.category.rawValue,
            xpReward: quest.xpReward
        )
    }
}

public struct QuestAppEntityQuery: EntityStringQuery {
    public init() {}

    public func entities(for identifiers: [UUID]) async throws -> [QuestAppEntity] {
        let quests = try await availableQuests()
        return quests.filter { identifiers.contains($0.id) }
    }

    public func suggestedEntities() async throws -> [QuestAppEntity] {
        try await availableQuests()
    }

    public func entities(matching string: String) async throws -> [QuestAppEntity] {
        try await availableQuests().filter {
            $0.title.localizedCaseInsensitiveContains(string)
        }
    }

    private func availableQuests() async throws -> [QuestAppEntity] {
        try await MainActor.run {
            let context = ModelContext(ALIVEModelContainer.shared)
            let quests = try context.fetch(FetchDescriptor<Quest>())

            return quests
                .filter { !$0.isCompleted }
                .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
                .map(QuestAppEntity.init(quest:))
        }
    }
}

public struct OpenALIVEDestinationIntent: AppIntent, OpenIntent {
    public static var title: LocalizedStringResource = "Open ALIVE"
    public static var description = IntentDescription("Open a key destination in ALIVE.")

    @available(iOS 26.0, macOS 26.0, *)
    public static var supportedModes: IntentModes = [.foreground(.immediate)]

    @available(*, deprecated, message: "Use supportedModes on iOS 26 and later.")
    public static var openAppWhenRun: Bool { true }

    @Parameter(title: "Destination")
    public var target: ALIVEIntentDestination

    public init() {
        target = .today
    }

    public init(target: ALIVEIntentDestination) {
        self.target = target
    }

    public func perform() async throws -> some IntentResult & ProvidesDialog {
        ALIVEIntentRouteStore.request(target.route)
        return .result(dialog: "Opening \(target.rawValue) in ALIVE.")
    }
}

public struct StartFocusIntent: AppIntent {
    public static var title: LocalizedStringResource = "Start Focus in ALIVE"
    public static var description = IntentDescription("Open ALIVE and begin a focus session.")

    @available(iOS 26.0, macOS 26.0, *)
    public static var supportedModes: IntentModes = [.foreground(.immediate)]

    @available(*, deprecated, message: "Use supportedModes on iOS 26 and later.")
    public static var openAppWhenRun: Bool { true }

    public init() {}

    public func perform() async throws -> some IntentResult & ProvidesDialog {
        ALIVEIntentRouteStore.request(.startFocus)
        return .result(dialog: "Starting your focus session in ALIVE.")
    }
}

public struct CompleteQuestIntent: AppIntent {
    public static var title: LocalizedStringResource = "Complete ALIVE Quest"
    public static var description = IntentDescription("Claim the reward for a completed ALIVE quest.")

    @available(iOS 26.0, macOS 26.0, *)
    public static var supportedModes: IntentModes = [.background, .foreground(.deferred)]

    @Parameter(title: "Quest")
    public var quest: QuestAppEntity

    public init() {
        quest = QuestAppEntity(id: UUID(), title: "", category: "", xpReward: 0)
    }

    public init(quest: QuestAppEntity) {
        self.quest = quest
    }

    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let outcome = try await completeQuest(id: quest.id)

        guard let outcome else {
            return .result(dialog: "That quest has already been claimed.")
        }

        return .result(dialog: "Completed \(outcome.title). You earned \(outcome.xpGained) XP.")
    }

    private func completeQuest(id: UUID) async throws -> QuestCompletionOutcome? {
        try await MainActor.run {
            let context = ModelContext(ALIVEModelContainer.shared)
            let quests = try context.fetch(FetchDescriptor<Quest>())
            guard let quest = quests.first(where: { $0.id == id }) else {
                throw ALIVEIntentError.questNotFound
            }

            let profiles = try context.fetch(FetchDescriptor<UserProfile>())
            guard let profile = profiles.first else {
                throw ALIVEIntentError.profileNotFound
            }

            return try QuestProgressEngine.complete(quest: quest, profile: profile, context: context)
        }
    }
}

public struct ALIVEAppShortcuts: AppShortcutsProvider {
    public static var shortcutTileColor: ShortcutTileColor = .blue

    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartFocusIntent(),
            phrases: [
                "Start focus in \(.applicationName)",
                "Begin a focus session with \(.applicationName)"
            ],
            shortTitle: "Start Focus",
            systemImageName: "timer"
        )

        AppShortcut(
            intent: OpenALIVEDestinationIntent(target: .quests),
            phrases: [
                "Open my quest board in \(.applicationName)",
                "Show my quests in \(.applicationName)"
            ],
            shortTitle: "Open Quests",
            systemImageName: "scroll.fill"
        )
    }
}

private enum ALIVEIntentError: LocalizedError {
    case profileNotFound
    case questNotFound

    var errorDescription: String? {
        switch self {
        case .profileNotFound:
            return "Create an ALIVE hero before completing quests from Shortcuts."
        case .questNotFound:
            return "That quest is no longer available."
        }
    }
}
