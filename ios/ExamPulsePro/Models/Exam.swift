import Foundation

struct Exam: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var date: Date
    var notes: String

    init(id: UUID = UUID(), title: String, date: Date, notes: String = "") {
        self.id = id
        self.title = title
        self.date = date
        self.notes = notes
    }

    func isPast(reference: Date = Date()) -> Bool {
        date <= reference
    }

    func countdownText(reference: Date = Date()) -> String {
        let diff = Int(date.timeIntervalSince(reference))
        if diff <= 0 {
            return "Exam time reached"
        }

        let days = diff / 86_400
        let hours = (diff % 86_400) / 3_600
        let minutes = (diff % 3_600) / 60
        let seconds = diff % 60
        return "\(days)d \(hours)h \(minutes)m \(seconds)s remaining"
    }
}
