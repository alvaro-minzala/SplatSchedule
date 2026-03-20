import Foundation
import Combine

@MainActor
class ScheduleService: ObservableObject {
    @Published var scheduleSlots: [GameMode: [ScheduleSlot]] = [:]
    @Published var isLoading = false
    @Published var lastUpdated: Date?
    @Published var errorMessage: String?

    private var refreshTimer: Timer?
    private let schedulesURL = URL(string: "https://splatoon3.ink/data/schedules.json")!

    private let dateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    init() {
        Task { await fetchAll() }
        startTimer()
    }

    func startTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30 * 60, repeats: true) { [weak self] _ in
            Task { await self?.fetchAll() }
        }
    }

    func fetchAll() async {
        isLoading = true
        errorMessage = nil
        await fetchSchedules()
        lastUpdated = Date()
        isLoading = false
    }

    func fetchSchedules() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: schedulesURL)
            let response = try JSONDecoder().decode(SchedulesResponse.self, from: data)
            parseSchedules(response.data)
        } catch {
            errorMessage = "Failed to load schedules: \(error.localizedDescription)"
        }
    }

    private func parseSchedules(_ data: SchedulesData) {
        var slots: [GameMode: [ScheduleSlot]] = [:]

        // Turf War
        let turfSlots = data.regularSchedules.nodes.compactMap { node -> ScheduleSlot? in
            guard let setting = node.regularMatchSetting,
                  let start = dateFormatter.date(from: node.startTime),
                  let end = dateFormatter.date(from: node.endTime) else { return nil }
            return ScheduleSlot(startTime: start, endTime: end, mode: .turfWar, ruleName: setting.vsRule.name, stages: setting.vsStages)
        }
        slots[.turfWar] = turfSlots

        // Anarchy
        var openSlots: [ScheduleSlot] = []
        var seriesSlots: [ScheduleSlot] = []
        for node in data.bankaraSchedules.nodes {
            guard let settings = node.bankaraMatchSettings,
                  let start = dateFormatter.date(from: node.startTime),
                  let end = dateFormatter.date(from: node.endTime) else { continue }
            for setting in settings {
                let mode: GameMode = setting.bankaraMode == "OPEN" ? .anarchyOpen : .anarchySeries
                let slot = ScheduleSlot(startTime: start, endTime: end, mode: mode, ruleName: setting.vsRule.name, stages: setting.vsStages)
                if mode == .anarchyOpen { openSlots.append(slot) } else { seriesSlots.append(slot) }
            }
        }
        slots[.anarchyOpen] = openSlots
        slots[.anarchySeries] = seriesSlots

        // X Battle
        let xSlots = data.xSchedules.nodes.compactMap { node -> ScheduleSlot? in
            guard let setting = node.xMatchSetting,
                  let start = dateFormatter.date(from: node.startTime),
                  let end = dateFormatter.date(from: node.endTime) else { return nil }
            return ScheduleSlot(startTime: start, endTime: end, mode: .xBattle, ruleName: setting.vsRule.name, stages: setting.vsStages)
        }
        slots[.xBattle] = xSlots

        scheduleSlots = slots
    }

}
