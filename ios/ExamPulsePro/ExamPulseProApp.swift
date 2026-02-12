import SwiftUI

@main
struct ExamPulseProApp: App {
    @StateObject private var store = ExamStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
