import SwiftUI

@main
struct FizyoKantikApp: App {
    @StateObject private var session = SessionStore.shared

    init() {
        // iOS TabBar & NavigationBar Dark Theme Configuration
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color(hex: 0x1E293B)) // Theme.darkSurface

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(Color(hex: 0x1E293B))
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if session.girisYapildi {
                    DashboardView(session: session)
                } else {
                    LoginView(session: session)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

