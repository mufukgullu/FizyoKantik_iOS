import SwiftUI
import UIKit

@main
struct FizyoKantikApp: App {
    @StateObject private var session = SessionStore.shared

    init() {
        // iOS TabBar & NavigationBar Dark Theme Configuration
        let darkSurface = UIColor(red: 30/255.0, green: 41/255.0, blue: 59/255.0, alpha: 1.0)

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = darkSurface

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = darkSurface
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

