import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: ExamStore

    @State private var title = ""
    @State private var notes = ""
    @State private var examDate = Date().addingTimeInterval(86_400)
    @State private var bulkInput = ""
    @State private var importedCount = 0
    @State private var showingClearConfirmation = false

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var now = Date()

    var body: some View {
        NavigationStack {
            List {
                Section("Exam Pulse Pro") {
                    LabeledContent("Mode", value: "Local only (no networking)")
                    LabeledContent("Timezone", value: store.timezoneLabel)
                    LabeledContent("Total Exams", value: "\(store.sortedExams.count)")
                    LabeledContent("Next Exam", value: store.nextExam?.title ?? "None yet")
                }

                Section("Add Exam") {
                    TextField("Exam name", text: $title)
                    DatePicker("Exam date", selection: $examDate)
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                    Button("Add to dashboard") {
                        store.add(title: title, date: examDate, notes: notes)
                        title = ""
                        notes = ""
                    }
                    .buttonStyle(.borderedProminent)
                }

                Section("Bulk Import") {
                    Text("Use one exam per line: Title | YYYY-MM-DD | HH:MM")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("Calculus Final | 2026-05-10 | 09:00", text: $bulkInput, axis: .vertical)
                        .lineLimit(4, reservesSpace: true)
                    Button("Import lines") {
                        importedCount = store.importLines(bulkInput)
                        if importedCount > 0 {
                            bulkInput = ""
                        }
                    }
                    if importedCount > 0 {
                        Text("Imported \(importedCount) exam(s).")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }

                Section("Countdown Dashboard") {
                    if store.sortedExams.isEmpty {
                        Text("No exams yet. Add one to start your precision countdown dashboard.")
                            .foregroundStyle(.secondary)
                    }

                    ForEach(store.sortedExams) { exam in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(exam.title)
                                .font(.headline)
                            Text(exam.date.formatted(date: .abbreviated, time: .shortened))
                                .foregroundStyle(.secondary)
                            Text(exam.countdownText(reference: now))
                                .foregroundStyle(exam.isPast(reference: now) ? .orange : .green)
                                .fontWeight(.semibold)
                            if !exam.notes.isEmpty {
                                Text(exam.notes)
                                    .font(.subheadline)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { indexes in
                        let ids = Set(indexes.map { store.sortedExams[$0].id })
                        store.delete(ids: ids)
                    }
                }

                Section {
                    Button("Clear all exams", role: .destructive) {
                        showingClearConfirmation = true
                    }
                }
            }
            .navigationTitle("Exam Pulse Pro")
            .onReceive(ticker) { date in
                now = date
            }
            .confirmationDialog("Remove all exams from this device?", isPresented: $showingClearConfirmation) {
                Button("Remove all", role: .destructive) {
                    store.clearAll()
                }
            }
        }
    }
}
