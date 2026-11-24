import SwiftUI

@main
struct N2ShoppeApp: App {
    @StateObject private var catalog = CatalogStore()

    var body: some Scene {
        WindowGroup {
            MainTabs()
                .environmentObject(catalog)
                .tint(.n2Red)
                .task { await catalog.refresh() }
        }
    }
}

extension Color {
    static let n2Red = Color(red: 0.73, green: 0.08, blue: 0.13)
    static let n2Bg = Color(red: 0.975, green: 0.972, blue: 0.97)
}
