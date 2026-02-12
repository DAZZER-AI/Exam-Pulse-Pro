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
            ScrollView {
                VStack(spacing: 14) {
                    heroCard
                    addExamCard
                    bulkImportCard
                    dashboardCard
                    dangerCard
                }
                .padding(16)
            }
            .background(backgroundGradient.ignoresSafeArea())
            .navigationTitle("Exam Pulse Pro")
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(ticker) { date in
                now = date
            }
            .confirmationDialog("Remove all exams from this device?", isPresented: $showingClearConfirmation) {
                Button("Remove all", role: .destructive) {
                    store.clearAll()
                }
            }
        }
        .tint(Color(hex: "7FA0FF"))
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Built for students.")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("A calm, modern way to track every exam countdown.")
                .font(.title3.weight(.semibold))
            infoLine("Mode", "Local-only, offline")
            infoLine("Timezone", store.timezoneLabel)
            infoLine("Total Exams", "\(store.sortedExams.count)")
            infoLine("Next Exam", store.nextExam?.title ?? "None yet")
        }
        .cardStyle()
    }

    private var addExamCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Add exam")
                .font(.headline)

            TextField("Exam name", text: $title)
                .fieldStyle()

            DatePicker("Exam date", selection: $examDate)
                .padding(10)
                .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            TextField("Notes (optional)", text: $notes, axis: .vertical)
                .lineLimit(3, reservesSpace: true)
                .fieldStyle()

            Button("Add to dashboard") {
                store.add(title: title, date: examDate, notes: notes)
                title = ""
                notes = ""
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .cardStyle()
    }

    private var bulkImportCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Bulk import")
                .font(.headline)
            Text("Use one exam per line: Title | YYYY-MM-DD | HH:MM")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField("Calculus Final | 2026-05-10 | 09:00", text: $bulkInput, axis: .vertical)
                .lineLimit(4, reservesSpace: true)
                .fieldStyle()

            Button("Import lines") {
                importedCount = store.importLines(bulkInput)
                if importedCount > 0 {
                    bulkInput = ""
                }
            }
            .buttonStyle(.bordered)

            if importedCount > 0 {
                Text("Imported \(importedCount) exam(s).")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        }
        .cardStyle()
    }

    private var dashboardCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Countdown dashboard")
                .font(.headline)

            if store.sortedExams.isEmpty {
                Text("No exams yet. Add one to start your precision countdown dashboard.")
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            } else {
                ForEach(store.sortedExams) { exam in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(exam.title)
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                        }

                        Text(exam.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(exam.countdownText(reference: now))
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(exam.isPast(reference: now) ? .orange : Color(hex: "7EE7C4"))

                        if !exam.notes.isEmpty {
                            Text(exam.notes)
                                .font(.footnote)
                        }

                        Button(role: .destructive) {
                            store.delete(ids: [exam.id])
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .font(.caption)
                        }
                    }
                    .padding(10)
                    .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .cardStyle()
    }

    private var dangerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Reset")
                .font(.headline)
            Button("Clear all exams", role: .destructive) {
                showingClearConfirmation = true
            }
            .buttonStyle(.bordered)
        }
        .cardStyle()
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "080A0F"), Color(hex: "101726"), Color(hex: "121a2f")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    @ViewBuilder
    private func infoLine(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}

private extension View {
    func cardStyle() -> some View {
        self
            .padding(14)
            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }

    func fieldStyle() -> some View {
        self
            .padding(10)
            .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)

        let red = Double((int >> 16) & 0xFF) / 255
        let green = Double((int >> 8) & 0xFF) / 255
        let blue = Double(int & 0xFF) / 255

        self.init(red: red, green: green, blue: blue)
    }
}
