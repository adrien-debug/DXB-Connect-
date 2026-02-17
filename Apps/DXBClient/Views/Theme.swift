import SwiftUI

// MARK: - Theme Mode Manager

enum AppearanceMode: String {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
}

// MARK: - Dynamic Theme with Dark Mode Support

struct AppTheme {
    // MARK: - Adaptive Colors (Light/Dark)

    // Primary colors - adapt to scheme
    static var primary: Color { adaptiveColor(light: "000000", dark: "FFFFFF") }
    static var primaryLight: Color { adaptiveColor(light: "3F3F46", dark: "A1A1AA") }
    static var primaryDark: Color { adaptiveColor(light: "000000", dark: "FFFFFF") }
    static var primarySoft: Color { adaptiveColor(light: "F4F4F5", dark: "27272A") }

    // Grayscale Spectrum
    static var gray50: Color { adaptiveColor(light: "FAFAFA", dark: "18181B") }
    static var gray100: Color { adaptiveColor(light: "F4F4F5", dark: "27272A") }
    static var gray200: Color { adaptiveColor(light: "E4E4E7", dark: "3F3F46") }
    static var gray300: Color { adaptiveColor(light: "D4D4D8", dark: "52525B") }
    static var gray400: Color { adaptiveColor(light: "A1A1AA", dark: "71717A") }
    static var gray500: Color { adaptiveColor(light: "71717A", dark: "A1A1AA") }
    static var gray600: Color { adaptiveColor(light: "52525B", dark: "D4D4D8") }
    static var gray700: Color { adaptiveColor(light: "3F3F46", dark: "E4E4E7") }
    static var gray800: Color { adaptiveColor(light: "27272A", dark: "F4F4F5") }
    static var gray900: Color { adaptiveColor(light: "18181B", dark: "FAFAFA") }

    // Semantic - Minimal colors
    static var success: Color { adaptiveColor(light: "22C55E", dark: "4ADE80") }
    static var successLight: Color { adaptiveColor(light: "F0FDF4", dark: "14532D") }
    static var warning: Color { adaptiveColor(light: "F59E0B", dark: "FBBF24") }
    static var warningLight: Color { adaptiveColor(light: "FFFBEB", dark: "451A03") }
    static var error: Color { adaptiveColor(light: "EF4444", dark: "F87171") }
    static var errorLight: Color { adaptiveColor(light: "FEF2F2", dark: "450A0A") }
    static var info: Color { adaptiveColor(light: "3B82F6", dark: "60A5FA") }

    // Backgrounds
    static var backgroundPrimary: Color { adaptiveColor(light: "FFFFFF", dark: "09090B") }
    static var backgroundSecondary: Color { adaptiveColor(light: "FAFAFA", dark: "18181B") }
    static var backgroundTertiary: Color { adaptiveColor(light: "F4F4F5", dark: "27272A") }

    // Surface - Clean layers
    static var surfaceLight: Color { adaptiveColor(light: "FFFFFF", dark: "18181B") }
    static var surfaceMedium: Color { adaptiveColor(light: "FAFAFA", dark: "27272A") }
    static var surfaceHeavy: Color { adaptiveColor(light: "F4F4F5", dark: "3F3F46") }

    // Text - High contrast
    static var textPrimary: Color { adaptiveColor(light: "000000", dark: "FAFAFA") }
    static var textSecondary: Color { adaptiveColor(light: "52525B", dark: "A1A1AA") }
    static var textTertiary: Color { adaptiveColor(light: "A1A1AA", dark: "71717A") }
    static var textMuted: Color { adaptiveColor(light: "D4D4D8", dark: "52525B") }

    // Borders - Precise lines
    static var border: Color { adaptiveColor(light: "E4E4E7", dark: "3F3F46") }
    static var borderLight: Color { adaptiveColor(light: "F4F4F5", dark: "27272A") }
    static var borderDark: Color { adaptiveColor(light: "D4D4D8", dark: "52525B") }

    // Solid colors for gradients
    static var brandGradient: Color { primary }
    static var heroGradient: Color { backgroundPrimary }
    static var deepVioletGradient: Color { primary }
    static var lightVioletGradient: Color { backgroundPrimary }
    static var cardGradient: Color { backgroundPrimary }

    // Glass surfaces
    static var glassLight: Color { adaptiveColor(light: "FFFFFF", dark: "18181B") }
    static var glassMedium: Color { adaptiveColor(light: "FFFFFF", dark: "27272A") }
    static var glassDark: Color { adaptiveColor(light: "FFFFFF", dark: "3F3F46") }
    static var glassViolet: Color { backgroundPrimary }

    // Accents - Monochrome
    static var accent1: Color { primary }
    static var accent2: Color { adaptiveColor(light: "3F3F46", dark: "A1A1AA") }
    static var accent3: Color { adaptiveColor(light: "71717A", dark: "71717A") }
    static var accent4: Color { primary }
    static var accent5: Color { primary }

    // Compatibility aliases
    static var violet50: Color { gray50 }
    static var violet100: Color { gray100 }
    static var violet200: Color { gray200 }
    static var violet300: Color { gray300 }
    static var violet400: Color { gray400 }
    static var violet500: Color { gray500 }
    static var violet600: Color { gray600 }
    static var violet700: Color { gray700 }
    static var violet800: Color { gray800 }
    static var violet900: Color { gray900 }

    // Alias
    static var brand: Color { primary }

    // MARK: - Theme State

    private static var currentMode: AppearanceMode = .system

    static func setAppearance(_ mode: AppearanceMode) {
        currentMode = mode
        // Force UI update
        NotificationCenter.default.post(name: .themeDidChange, object: nil)
    }

    static var isDarkMode: Bool {
        switch currentMode {
        case .light:
            return false
        case .dark:
            return true
        case .system:
            return UITraitCollection.current.userInterfaceStyle == .dark
        }
    }

    // Helper to create adaptive colors
    private static func adaptiveColor(light: String, dark: String) -> Color {
        Color(UIColor { traitCollection in
            let useDark: Bool
            switch currentMode {
            case .light:
                useDark = false
            case .dark:
                useDark = true
            case .system:
                useDark = traitCollection.userInterfaceStyle == .dark
            }
            return UIColor(Color(hex: useDark ? dark : light))
        })
    }
}

// MARK: - Notification for Theme Changes

extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - Clean Tech Cards

struct TechCard: ViewModifier {
    var padding: CGFloat = 20
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.02), radius: 1, x: 0, y: 1)
            )
    }
}

struct GlassCard: ViewModifier {
    var padding: CGFloat = 20
    var cornerRadius: CGFloat = 16
    var opacity: Double = 1.0

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.02), radius: 1, x: 0, y: 1)
            )
    }
}

struct PremiumCard: ViewModifier {
    var padding: CGFloat = 20
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.02), radius: 1, x: 0, y: 1)
            )
    }
}

extension View {
    func techCard(padding: CGFloat = 20, cornerRadius: CGFloat = 16) -> some View {
        modifier(TechCard(padding: padding, cornerRadius: cornerRadius))
    }

    func glassCard(padding: CGFloat = 20, cornerRadius: CGFloat = 16, opacity: Double = 1.0) -> some View {
        modifier(TechCard(padding: padding, cornerRadius: cornerRadius))
    }

    func premiumCard(padding: CGFloat = 20, cornerRadius: CGFloat = 16) -> some View {
        modifier(TechCard(padding: padding, cornerRadius: cornerRadius))
    }

    func cleanCard(cornerRadius: CGFloat = 16, shadow: Bool = true) -> some View {
        modifier(TechCard(padding: 0, cornerRadius: cornerRadius))
    }

    func premiumGlass(cornerRadius: CGFloat = 16) -> some View {
        modifier(TechCard(padding: 0, cornerRadius: cornerRadius))
    }
}

// MARK: - Animations

struct FloatingAnimation: ViewModifier {
    @State private var offset: CGFloat = 0
    let duration: Double
    let distance: CGFloat

    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    offset = -distance
                }
            }
    }
}

struct ScaleOnPress: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: isPressed)
            .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
    }
}

struct SlideIn: ViewModifier {
    @State private var appeared = false
    let delay: Double

    func body(content: Content) -> some View {
        content
            .offset(y: appeared ? 0 : 20)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(delay)) {
                    appeared = true
                }
            }
    }
}

extension View {
    func floating(duration: Double = 3, distance: CGFloat = 6) -> some View {
        modifier(FloatingAnimation(duration: duration, distance: distance))
    }

    func scaleOnPress() -> some View {
        modifier(ScaleOnPress())
    }

    func slideIn(delay: Double = 0) -> some View {
        modifier(SlideIn(delay: delay))
    }

    func pulse() -> some View {
        self
    }
}

// MARK: - Blur Background

struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
