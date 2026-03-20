import Foundation

// MARK: - Schedules

struct SchedulesResponse: Codable {
    let data: SchedulesData
}

struct SchedulesData: Codable {
    let regularSchedules: NodeList<RegularSchedule>
    let bankaraSchedules: NodeList<BankaraSchedule>
    let xSchedules: NodeList<XSchedule>
    let festSchedules: NodeList<FestSchedule>?
}

struct NodeList<T: Codable>: Codable {
    let nodes: [T]
}

// MARK: - Regular (Turf War)

struct RegularSchedule: Codable, Identifiable {
    var id: String { startTime }
    let startTime: String
    let endTime: String
    let regularMatchSetting: RegularMatchSetting?
    let festMatchSettings: [FestMatchSetting]?
}

struct RegularMatchSetting: Codable {
    let vsStages: [VsStage]
    let vsRule: VsRule
}

// MARK: - Bankara (Anarchy)

struct BankaraSchedule: Codable, Identifiable {
    var id: String { startTime }
    let startTime: String
    let endTime: String
    let bankaraMatchSettings: [BankaraMatchSetting]?
}

struct BankaraMatchSetting: Codable {
    let vsStages: [VsStage]
    let vsRule: VsRule
    let bankaraMode: String
}

// MARK: - X Battle

struct XSchedule: Codable, Identifiable {
    var id: String { startTime }
    let startTime: String
    let endTime: String
    let xMatchSetting: XMatchSetting?
}

struct XMatchSetting: Codable {
    let vsStages: [VsStage]
    let vsRule: VsRule
}

// MARK: - Fest

struct FestSchedule: Codable, Identifiable {
    var id: String { startTime }
    let startTime: String
    let endTime: String
    let festMatchSettings: [FestMatchSetting]?
}

struct FestMatchSetting: Codable {
    let vsStages: [VsStage]
    let vsRule: VsRule
}

// MARK: - Shared

struct VsStage: Codable, Identifiable {
    let vsStageId: Int
    var id: Int { vsStageId }
    let name: String
    let image: SplatImage
}

struct VsRule: Codable {
    let name: String
    let rule: String
}

struct SplatImage: Codable {
    let url: String
}

// MARK: - View Model

enum GameMode: String, CaseIterable, Identifiable {
    case turfWar = "Turf War"
    case anarchyOpen = "Anarchy Open"
    case anarchySeries = "Anarchy Series"
    case xBattle = "X Battle"

    var id: String { rawValue }

    var accentColor: String {
        switch self {
        case .turfWar: return "#C8E645"
        case .anarchyOpen: return "#F54910"
        case .anarchySeries: return "#F54910"
        case .xBattle: return "#0FDB9B"
        }
    }
}

struct ScheduleSlot: Identifiable {
    let id = UUID()
    let startTime: Date
    let endTime: Date
    let mode: GameMode
    let ruleName: String
    let stages: [VsStage]
    var isActive: Bool {
        let now = Date()
        return now >= startTime && now < endTime
    }
}


