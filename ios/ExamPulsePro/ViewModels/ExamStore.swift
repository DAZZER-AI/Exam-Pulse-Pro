import Foundation
import Combine

final class ExamStore: ObservableObject {
    @Published private(set) var exams: [Exam] = []

    private let storageKey = "exam-pulse-pro.ios.exams.v1"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        load()
    }

    var sortedExams: [Exam] {
        exams.sorted { $0.date < $1.date }
    }

    var nextExam: Exam? {
        sortedExams.first
    }

    var timezoneLabel: String {
        TimeZone.current.identifier
    }

    func add(title: String, date: Date, notes: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let exam = Exam(title: trimmedTitle, date: date, notes: notes.trimmingCharacters(in: .whitespacesAndNewlines))
        exams.append(exam)
        persist()
    }

    func delete(ids: Set<UUID>) {
        exams.removeAll { ids.contains($0.id) }
        persist()
    }

    func clearAll() {
        exams = []
        persist()
    }

    @discardableResult
    func importLines(_ source: String) -> Int {
        let lines = source
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !lines.isEmpty else { return 0 }

        let parser = DateParser()
        var additions: [Exam] = []

        for line in lines {
            let parts = line.split(separator: "|").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            guard let title = parts.first, !title.isEmpty else { continue }
            guard parts.count >= 2 else { continue }

            let dateString = parts[1]
            let timeString = parts.count > 2 ? parts[2] : "09:00"

            guard let parsedDate = parser.date(date: dateString, time: timeString) else { continue }
            additions.append(Exam(title: title, date: parsedDate))
        }

        if !additions.isEmpty {
            exams.append(contentsOf: additions)
            persist()
        }

        return additions.count
    }

    private func persist() {
        guard let data = try? encoder.encode(exams) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            exams = []
            return
        }

        exams = (try? decoder.decode([Exam].self, from: data)) ?? []
    }
}

private struct DateParser {
    private let formatter: DateFormatter

    init() {
        formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
    }

    func date(date: String, time: String) -> Date? {
        formatter.date(from: "\(date) \(time)")
    }
}
