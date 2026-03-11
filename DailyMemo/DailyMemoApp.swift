import SwiftUI
import SwiftData

/// DailyMemo 앱의 진입점
@main
struct DailyMemoApp: App {

    var body: some Scene {
        WindowGroup {
            MemoListView()
        }
        .modelContainer(for: Memo.self)
    }
}
