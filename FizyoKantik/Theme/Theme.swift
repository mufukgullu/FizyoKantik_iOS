import SwiftUI

enum Theme {
    static let emeraldPrimary = Color(hex: 0x10B981)
    static let emeraldDark = Color(hex: 0x047857)
    static let emeraldLight = Color(hex: 0x34D399)
    static let emeraldContainer = Color(hex: 0x064E3B)

    static let cyanAccent = Color(hex: 0x06B6D4)
    static let cyanDark = Color(hex: 0x0E7490)

    static let darkBg = Color(hex: 0x0F172A)
    static let darkSurface = Color(hex: 0x1E293B)
    static let darkSurfaceElevated = Color(hex: 0x334155)
    static let darkBorder = Color(hex: 0x475569)

    static let textPrimary = Color(hex: 0xF8FAFC)
    static let textSecondary = Color(hex: 0x94A3B8)
    static let textMuted = Color(hex: 0x64748B)

    static let statusSuccess = Color(hex: 0x22C55E)
    static let statusWarning = Color(hex: 0xF59E0B)
    static let statusError = Color(hex: 0xEF4444)
    static let statusInfo = Color(hex: 0x38BDF8)
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
