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
    let coopGroupingSchedule: CoopGroupingSchedule?
}

// MARK: - Coop (Salmon Run — from schedules.json)

struct CoopGroupingSchedule: Codable {
    let regularSchedules: NodeList<CoopSchedule>?
    let bigRunSchedules: NodeList<CoopSchedule>?
    let teamContestSchedules: NodeList<CoopSchedule>?
}

struct CoopSchedule: Codable, Identifiable {
    var id: String { startTime }
    let startTime: String
    let endTime: String
    let setting: CoopSetting?
}

struct CoopSetting: Codable {
    let coopStage: CoopStage
    let weapons: [CoopWeapon]
    let boss: CoopBoss?
}

struct CoopStage: Codable {
    let name: String
    let image: SplatImage
}

struct CoopWeapon: Codable {
    let name: String
    let image: SplatImage
}

struct CoopBoss: Codable {
    let name: String
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
    case salmonRun = "Salmon Run"

    var id: String { rawValue }

    var accentColor: String {
        switch self {
        case .turfWar: return "#C8E645"
        case .anarchyOpen: return "#F54910"
        case .anarchySeries: return "#F54910"
        case .xBattle: return "#0FDB9B"
        case .salmonRun: return "#FF6B1A"
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

struct CoopSlot: Identifiable {
    let id = UUID()
    let startTime: Date
    let endTime: Date
    let stageName: String
    let stageImageURL: String
    let weapons: [String]
    let weaponImageURLs: [String]
    let bossName: String?
    let coopMode: CoopMode
    var isActive: Bool {
        let now = Date()
        return now >= startTime && now < endTime
    }
}

enum CoopMode: String {
    case regular = "Salmon Run"
    case bigRun = "Big Run"
    case eggstraWork = "Eggstra Work"
}


