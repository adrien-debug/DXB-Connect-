import SwiftUI

// MARK: - Theme Mode Manager

enum AppearanceMode: String {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
}

// MARK: - Dynamic Theme with Dark Mode Support

struct AppTheme {
    // MARK: - Spacing Scale (8pt Grid System)

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let base: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 48
    }

    // MARK: - Corner Radius Scale

    enum Radius {
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 28
        static let full: CGFloat = 9999
    }

    // MARK: - Typography Presets (Aurora)

    enum Typography {
        static func display() -> Font { .system(size: 52, weight: .bold, design: .rounded) }
        static func heroStat() -> Font { .system(size: 44, weight: .bold, design: .rounded) }
        static func heroAmount() -> Font { .system(size: 42, weight: .bold, design: .rounded) }
        static func detailAmount() -> Font { .system(size: 32, weight: .bold, design: .rounded) }
        static func headline() -> Font { .system(size: 26, weight: .semibold, design: .rounded) }

        static func title1() -> Font { .system(size: 22, weight: .semibold, design: .rounded) }
        static func title2() -> Font { .system(size: 18, weight: .semibold, design: .rounded) }
        static func sectionTitle() -> Font { .system(size: 20, weight: .semibold, design: .rounded) }
        static func cardAmount() -> Font { .system(size: 18, weight: .semibold, design: .rounded) }
        static func cardTitle() -> Font { .system(size: 20, weight: .bold, design: .rounded) }

        static func bodyLarge() -> Font { .system(size: 17, weight: .regular) }
        static func body() -> Font { .system(size: 15, weight: .regular) }
        static func bodyMedium() -> Font { .system(size: 15, weight: .medium) }
        static func bodySemibold() -> Font { .system(size: 15, weight: .semibold) }

        static func caption() -> Font { .system(size: 13, weight: .regular) }
        static func captionMedium() -> Font { .system(size: 13, weight: .medium) }
        static func captionSemibold() -> Font { .system(size: 13, weight: .semibold) }
        static func small() -> Font { .system(size: 11, weight: .regular) }
        static func smallMedium() -> Font { .system(size: 11, weight: .medium) }
        static func smallBold() -> Font { .system(size: 11, weight: .bold) }

        static func navTitle() -> Font { .system(size: 12, weight: .bold) }
        static func tabLabel() -> Font { .system(size: 10, weight: .medium) }
        static func button() -> Font { .system(size: 14, weight: .semibold) }
        static func buttonLarge() -> Font { .system(size: 17, weight: .semibold) }
        static func buttonMedium() -> Font { .system(size: 15, weight: .semibold) }
        static func buttonSmall() -> Font { .system(size: 13, weight: .semibold) }
        static func label() -> Font { .system(size: 10, weight: .bold) }
        static func overline() -> Font { .system(size: 11, weight: .bold) }
        static func mono() -> Font { .system(size: 13, weight: .medium, design: .monospaced) }

        static func icon(size: CGFloat) -> Font { .system(size: size, weight: .medium) }
        static func iconBold(size: CGFloat) -> Font { .system(size: size, weight: .bold) }
        static func iconSemibold(size: CGFloat) -> Font { .system(size: size, weight: .semibold) }
    }

    // MARK: - Banking UI Tokens

    enum Banking {
        enum Spacing {
            static let xs: CGFloat = AppTheme.Spacing.xs
            static let sm: CGFloat = AppTheme.Spacing.sm
            static let md: CGFloat = AppTheme.Spacing.md
            static let base: CGFloat = AppTheme.Spacing.base
            static let lg: CGFloat = AppTheme.Spacing.lg
            static let xl: CGFloat = AppTheme.Spacing.xl
            static let xxl: CGFloat = AppTheme.Spacing.xxl
            static let xxxl: CGFloat = AppTheme.Spacing.xxxl
        }

        enum Radius {
            static let chartBar: CGFloat = 8
            static let small: CGFloat = 10
            static let medium: CGFloat = 14
            static let card: CGFloat = 18
            static let pill: CGFloat = 9999
        }

        enum Typography {
            static func heroAmount() -> Font { .system(size: 36, weight: .bold) }
            static func detailAmount() -> Font { .system(size: 32, weight: .bold) }
            static func sectionTitle() -> Font { .system(size: 16, weight: .semibold) }
            static func cardAmount() -> Font { .system(size: 18, weight: .semibold) }
            static func body() -> Font { .system(size: 14, weight: .regular) }
            static func caption() -> Font { .system(size: 12, weight: .regular) }
            static func small() -> Font { .system(size: 11, weight: .regular) }
            static func navTitle() -> Font { .system(size: 12, weight: .semibold) }
            static func tabLabel() -> Font { .system(size: 13, weight: .medium) }
            static func button() -> Font { .system(size: 14, weight: .semibold) }
            static func label() -> Font { .system(size: 10, weight: .semibold) }
        }

        enum Colors {
            static var accent: Color { Color(hex: "D6FB51") }
            static var accentLight: Color { Color(hex: "E0FC7C") }
            static var accentSoft: Color { Color(hex: "EAFDA8") }
            static var accentDark: Color { Color(hex: "B0CE46") }
            static var accentDeep: Color { Color(hex: "8AA13B") }

            static var backgroundPrimary: Color { Color(hex: "191919") }
            static var backgroundSecondary: Color { Color(hex: "2A2A2A") }
            static var backgroundTertiary: Color { Color(hex: "404040") }

            static var surfaceLight: Color { Color(hex: "F3F3F2") }
            static var surfaceMedium: Color { Color(hex: "E2E2E1") }
            static var surfaceHeavy: Color { Color(hex: "D0D0CF") }

            static var textOnDarkPrimary: Color { Color(hex: "FFFFFF") }
            static var textOnDarkSecondary: Color { Color(hex: "D0D0CF") }
            static var textOnDarkMuted: Color { Color(hex: "9C9C9B") }

            static var textOnLightPrimary: Color { Color(hex: "191919") }
            static var textOnLightSecondary: Color { Color(hex: "656463") }
            static var textOnLightMuted: Color { Color(hex: "A09F9D") }

            static var border: Color { Color(hex: "D0D0CF") }
            static var borderLight: Color { Color(hex: "E2E2E1") }
            static var borderDark: Color { Color(hex: "404040") }
        }

        enum Shadow {
            static let card = (color: Color.black.opacity(0.12), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(6))
        }
    }

    // MARK: - Core Brand Colors
    // Accent #BAFF39, Ink #0B0F1A, White #FFFFFF

    static var neonGreen: Color { Color(hex: "BAFF39") }
    static var darkGray: Color { Color(hex: "0B0F1A") }
    static var pureWhite: Color { Color(hex: "FFFFFF") }

    // MARK: - Premium Dark Surfaces (Aurora)

    static var surface1: Color { Color(hex: "0F172A") }
    static var surface2: Color { Color(hex: "111C2F") }
    static var surface3: Color { Color(hex: "16233D") }
    static var surfaceGlass: Color { Color.white.opacity(0.06) }

    // MARK: - Brand Ink

    static var anthracite: Color { Color(hex: "0B0F1A") }
    static var anthraciteLight: Color { Color(hex: "1F2937") }
    static var anthraciteDark: Color { Color(hex: "06090F") }

    // MARK: - Color Helpers

    static func color(_ hex: String) -> Color { Color(hex: hex) }

    // MARK: - Accent Color (#BAFF39)

    static var accent: Color { Color(hex: "BAFF39") }
    static var accentLight: Color { Color(hex: "BAFF39").opacity(0.7) }
    static var accentSoft: Color { Color(hex: "BAFF39").opacity(0.18) }

    // MARK: - Primary colors (Ink / white)

    static var primary: Color { adaptiveColor(light: "0B0F1A", dark: "F8FAFC") }
    static var primaryLight: Color { adaptiveColor(light: "1F2937", dark: "F8FAFC") }
    static var primaryDark: Color { adaptiveColor(light: "06090F", dark: "E2E8F0") }
    static var primarySoft: Color { adaptiveColor(light: "F1F5F9", dark: "1F2937") }

    // MARK: - Grayscale (slate)

    static var gray50: Color { Color(hex: "F8FAFC") }
    static var gray100: Color { Color(hex: "F1F5F9") }
    static var gray200: Color { Color(hex: "E2E8F0") }
    static var gray300: Color { Color(hex: "CBD5E1") }
    static var gray400: Color { Color(hex: "94A3B8") }
    static var gray500: Color { Color(hex: "64748B") }
    static var gray600: Color { Color(hex: "475569") }
    static var gray700: Color { Color(hex: "334155") }
    static var gray800: Color { Color(hex: "1F2937") }
    static var gray900: Color { Color(hex: "0F172A") }

    // MARK: - Semantic Colors

    static var success: Color { Color(hex: "34D399") }
    static var successLight: Color { Color(hex: "34D399").opacity(0.15) }
    static var warning: Color { Color(hex: "F59E0B") }
    static var warningLight: Color { Color(hex: "F59E0B").opacity(0.12) }
    static var error: Color { Color(hex: "F87171") }
    static var errorLight: Color { Color(hex: "F87171").opacity(0.15) }
    static var info: Color { Color(hex: "60A5FA") }

    // MARK: - Backgrounds

    static var backgroundPrimary: Color { adaptiveColor(light: "F8FAFC", dark: "0B0F1A") }
    static var backgroundSecondary: Color { adaptiveColor(light: "F1F5F9", dark: "111827") }
    static var backgroundTertiary: Color { adaptiveColor(light: "E2E8F0", dark: "1F2937") }

    // MARK: - Surfaces

    static var surfaceLight: Color { adaptiveColor(light: "FFFFFF", dark: "16233D") }
    static var surfaceMedium: Color { adaptiveColor(light: "F8FAFC", dark: "1B2A44") }
    static var surfaceHeavy: Color { adaptiveColor(light: "E2E8F0", dark: "0F172A") }

    // MARK: - Text

    static var textPrimary: Color { adaptiveColor(light: "0B0F1A", dark: "F8FAFC") }
    static var textSecondary: Color { adaptiveColor(light: "475569", dark: "94A3B8") }
    static var textTertiary: Color { adaptiveColor(light: "64748B", dark: "64748B") }
    static var textMuted: Color { adaptiveColor(light: "94A3B8", dark: "64748B") }

    // MARK: - Borders

    static var border: Color { adaptiveColor(light: "E2E8F0", dark: "23304A") }
    static var borderLight: Color { adaptiveColor(light: "F1F5F9", dark: "1B2A44") }
    static var borderDark: Color { adaptiveColor(light: "CBD5E1", dark: "0F172A") }

    // MARK: - Gradient helpers

    static var accentGradientStart: Color { Color(hex: "BAFF39") }
    static var accentGradientEnd: Color { Color(hex: "BAFF39").opacity(0.6) }
    static var heroGradient: Color { backgroundPrimary }

    // MARK: - Glass surfaces

    static var glassLight: Color { Color.white.opacity(0.08) }
    static var glassMedium: Color { Color.white.opacity(0.06) }
    static var glassDark: Color { Color.white.opacity(0.04) }

    // Compatibility aliases
    static var brand: Color { accent }
    static var brandGradient: Color { accent }
    static var deepVioletGradient: Color { primary }
    static var lightVioletGradient: Color { backgroundPrimary }
    static var cardGradient: Color { backgroundPrimary }
    static var glassViolet: Color { backgroundPrimary }
    static var accent1: Color { accent }
    static var accent2: Color { Color(hex: "1F2937") }
    static var accent3: Color { Color(hex: "334155") }
    static var accent4: Color { accent }
    static var accent5: Color { accent }
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

    // MARK: - Theme State

    private static var currentMode: AppearanceMode = .light

    static func setAppearance(_ mode: AppearanceMode) {
        currentMode = mode
        NotificationCenter.default.post(name: .themeDidChange, object: nil)
    }

    static var isDarkMode: Bool {
        switch currentMode {
        case .light: return false
        case .dark: return true
        case .system: return UITraitCollection.current.userInterfaceStyle == .dark
        }
    }

    private static func adaptiveColor(light: String, dark: String) -> Color {
        Color(UIColor { traitCollection in
            let useDark: Bool
            switch currentMode {
            case .light: useDark = false
            case .dark: useDark = true
            case .system: useDark = traitCollection.userInterfaceStyle == .dark
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

// MARK: - Card Modifiers

struct TechCard: ViewModifier {
    var padding: CGFloat = 20
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.surfaceLight, AppTheme.surfaceMedium],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(AppTheme.border.opacity(0.6), lineWidth: 0.8)
                    )
                    .shadow(color: AppTheme.surface1.opacity(0.6), radius: 12, x: 0, y: 8)
                    .shadow(color: Color.black.opacity(0.15), radius: 24, x: 0, y: 18)
            )
    }
}

struct GlassCard: ViewModifier {
    var padding: CGFloat = 20
    var cornerRadius: CGFloat = 20
    var opacity: Double = 1.0

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(AppTheme.surfaceGlass.opacity(opacity))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(AppTheme.border.opacity(0.4), lineWidth: 0.8)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 12)
            )
    }
}

struct PremiumCard: ViewModifier {
    var padding: CGFloat = 20
    var cornerRadius: CGFloat = 24

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.surfaceLight, AppTheme.surfaceHeavy],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [AppTheme.accent.opacity(0.35), AppTheme.border.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: AppTheme.surface1.opacity(0.6), radius: 14, x: 0, y: 10)
                    .shadow(color: Color.black.opacity(0.2), radius: 26, x: 0, y: 20)
            )
    }
}

extension View {
    func techCard(padding: CGFloat = 20, cornerRadius: CGFloat = 20) -> some View {
        modifier(TechCard(padding: padding, cornerRadius: cornerRadius))
    }

    func glassCard(padding: CGFloat = 20, cornerRadius: CGFloat = 20, opacity: Double = 1.0) -> some View {
        modifier(GlassCard(padding: padding, cornerRadius: cornerRadius, opacity: opacity))
    }

    func premiumCard(padding: CGFloat = 20, cornerRadius: CGFloat = 24) -> some View {
        modifier(PremiumCard(padding: padding, cornerRadius: cornerRadius))
    }

    func cleanCard(cornerRadius: CGFloat = 20, shadow: Bool = true) -> some View {
        modifier(TechCard(padding: 0, cornerRadius: cornerRadius))
    }

    func premiumGlass(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassCard(padding: 0, cornerRadius: cornerRadius))
    }
}

// MARK: - Animations

struct ScaleOnPress: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.975 : 1)
            .opacity(isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
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
            .offset(y: appeared ? 0 : 16)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.78).delay(delay)) {
                    appeared = true
                }
            }
    }
}

// MARK: - Floating Animation
struct Floating: ViewModifier {
    let duration: Double
    let distance: CGFloat
    @State private var isFloating = false

    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -distance : distance)
            .animation(
                .easeInOut(duration: duration).repeatForever(autoreverses: true),
                value: isFloating
            )
            .onAppear { isFloating = true }
    }
}

// MARK: - Shimmer Effect
struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.4),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: -geo.size.width + phase * geo.size.width * 3)
                    .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: phase)
                }
            )
            .mask(content)
            .onAppear { phase = 1 }
    }
}

// MARK: - Pulse Glow Effect
struct PulseGlow: ViewModifier {
    var color: Color = AppTheme.accent
    var radius: CGFloat = 20
    @State private var isGlowing = false

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(isGlowing ? 0.6 : 0.2), radius: isGlowing ? radius : radius / 2, x: 0, y: isGlowing ? 8 : 4)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isGlowing)
            .onAppear { isGlowing = true }
    }
}

// MARK: - Glow Button
struct GlowButton: ViewModifier {
    var color: Color = AppTheme.accent
    var cornerRadius: CGFloat = 18
    @State private var isGlowing = false

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(color)
                    .shadow(color: color.opacity(isGlowing ? 0.7 : 0.3), radius: isGlowing ? 24 : 12, x: 0, y: isGlowing ? 10 : 5)
            )
            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isGlowing)
            .onAppear { isGlowing = true }
    }
}

// MARK: - Glassmorphism
struct Glassmorphism: ViewModifier {
    var cornerRadius: CGFloat = 24
    var blur: CGFloat = 20
    var opacity: Double = 0.15

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(AppTheme.surfaceLight.opacity(opacity))
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.5), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
    }
}

// MARK: - Bounce In Animation
struct BounceIn: ViewModifier {
    @State private var appeared = false
    let delay: Double

    func body(content: Content) -> some View {
        content
            .scaleEffect(appeared ? 1 : 0.5)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(delay)) {
                    appeared = true
                }
            }
    }
}

// MARK: - 3D Flip
struct FlipCard: ViewModifier {
    @Binding var isFlipped: Bool
    var axis: (x: CGFloat, y: CGFloat, z: CGFloat) = (0, 1, 0)

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: axis
            )
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isFlipped)
    }
}

extension View {
    func floating(duration: Double = 3, distance: CGFloat = 6) -> some View {
        modifier(Floating(duration: duration, distance: distance))
    }
    func scaleOnPress() -> some View { modifier(ScaleOnPress()) }
    func slideIn(delay: Double = 0) -> some View { modifier(SlideIn(delay: delay)) }
    func bounceIn(delay: Double = 0) -> some View { modifier(BounceIn(delay: delay)) }
    func pulse(color: Color = AppTheme.accent, radius: CGFloat = 20) -> some View {
        modifier(PulseGlow(color: color, radius: radius))
    }
    func shimmer() -> some View { modifier(Shimmer()) }
    func glowButton(color: Color = AppTheme.accent, cornerRadius: CGFloat = 18) -> some View {
        modifier(GlowButton(color: color, cornerRadius: cornerRadius))
    }
    func glassmorphism(cornerRadius: CGFloat = 24, blur: CGFloat = 20, opacity: Double = 0.15) -> some View {
        modifier(Glassmorphism(cornerRadius: cornerRadius, blur: blur, opacity: opacity))
    }
    func flipCard(isFlipped: Binding<Bool>) -> some View {
        modifier(FlipCard(isFlipped: isFlipped))
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

// MARK: - Accent Button

struct NeonButton: ViewModifier {
    var color: Color = AppTheme.accent
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(color)
            )
    }
}

struct AccentBorderCard: ViewModifier {
    var isActive: Bool = false
    var cornerRadius: CGFloat = 18

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(AppTheme.backgroundPrimary)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                isActive ? AppTheme.accent.opacity(0.4) : AppTheme.border,
                                lineWidth: 1
                            )
                    )
            )
    }
}

struct ProgressBarStyle: ViewModifier {
    let progress: Double
    var height: CGFloat = 4
    var trackColor: Color = AppTheme.gray800
    var fillColor: Color = AppTheme.accent

    func body(content: Content) -> some View {
        content.overlay(
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(trackColor)
                        .frame(height: height)

                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(fillColor)
                        .frame(width: geo.size.width * min(max(progress, 0), 1), height: height)
                }
            }
            .frame(height: height)
        )
    }
}

extension View {
    func neonButton(color: Color = AppTheme.accent, cornerRadius: CGFloat = 16) -> some View {
        modifier(NeonButton(color: color, cornerRadius: cornerRadius))
    }

    func accentBorderCard(isActive: Bool = false, cornerRadius: CGFloat = 18) -> some View {
        modifier(AccentBorderCard(isActive: isActive, cornerRadius: cornerRadius))
    }
}

// MARK: - Haptic Feedback

enum HapticFeedback {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

// MARK: - Confetti Effect

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: Color
    var rotation: Double
    var scale: CGFloat
    var velocity: CGVector
    var angularVelocity: Double
}

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var isAnimating = false
    let colors: [Color] = [
        AppTheme.accent,
        AppTheme.success,
        .yellow,
        .orange,
        .pink,
        .purple,
        .cyan
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiPiece(particle: particle)
                }
            }
            .onAppear {
                createParticles(in: geo.size)
            }
        }
        .allowsHitTesting(false)
    }

    private func createParticles(in size: CGSize) {
        let centerX = size.width / 2
        particles = (0..<60).map { _ in
            ConfettiParticle(
                position: CGPoint(x: centerX + CGFloat.random(in: -50...50), y: -20),
                color: colors.randomElement()!,
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.2),
                velocity: CGVector(
                    dx: CGFloat.random(in: -8...8),
                    dy: CGFloat.random(in: 8...18)
                ),
                angularVelocity: Double.random(in: -15...15)
            )
        }
        isAnimating = true
    }
}

struct ConfettiPiece: View {
    let particle: ConfettiParticle
    @State private var position: CGPoint
    @State private var rotation: Double
    @State private var opacity: Double = 1

    init(particle: ConfettiParticle) {
        self.particle = particle
        _position = State(initialValue: particle.position)
        _rotation = State(initialValue: particle.rotation)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(particle.color)
            .frame(width: 8 * particle.scale, height: 12 * particle.scale)
            .rotationEffect(.degrees(rotation))
            .position(position)
            .opacity(opacity)
            .onAppear {
                withAnimation(.linear(duration: 3)) {
                    position.x += particle.velocity.dx * 60
                    position.y += particle.velocity.dy * 60
                    rotation += particle.angularVelocity * 60
                }
                withAnimation(.linear(duration: 3).delay(1.5)) {
                    opacity = 0
                }
            }
    }
}

// MARK: - Animated Mesh Gradient Header

struct AnimatedMeshGradient: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Gradient orbs that move slowly
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    gradientColor(for: index).opacity(0.5),
                                    gradientColor(for: index).opacity(0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: geo.size.width * 0.4
                            )
                        )
                        .frame(width: geo.size.width * 0.8, height: geo.size.width * 0.8)
                        .offset(
                            x: animate ? orbOffset(index: index, axis: .x, size: geo.size) : -orbOffset(index: index, axis: .x, size: geo.size),
                            y: animate ? orbOffset(index: index, axis: .y, size: geo.size) : -orbOffset(index: index, axis: .y, size: geo.size)
                        )
                        .animation(
                            .easeInOut(duration: Double(4 + index))
                                .repeatForever(autoreverses: true),
                            value: animate
                        )
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onAppear { animate = true }
    }

    private func gradientColor(for index: Int) -> Color {
        let colors: [Color] = [
            AppTheme.accent.opacity(0.3),
            AppTheme.accent.opacity(0.15),
            Color(hex: "E5E5E5"),
            Color(hex: "F5F5F5")
        ]
        return colors[index % colors.count]
    }

    private enum Axis { case x, y }

    private func orbOffset(index: Int, axis: Axis, size: CGSize) -> CGFloat {
        let baseOffset: CGFloat = axis == .x ? size.width * 0.15 : size.height * 0.15
        let multiplier: CGFloat = CGFloat((index % 2 == 0) ? 1 : -1)
        return baseOffset * multiplier * CGFloat(index + 1) * 0.3
    }
}

// MARK: - Shimmer Placeholder

struct ShimmerPlaceholder: View {
    var cornerRadius: CGFloat = 12
    @State private var phase: CGFloat = 0

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(AppTheme.gray800)
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.2),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width)
                    .offset(x: -geo.size.width + phase * geo.size.width * 2)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

// MARK: - Animated Tab Icon

struct AnimatedTabIcon: View {
    let systemName: String
    let isSelected: Bool
    @State private var bounce = false

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
            .foregroundColor(isSelected ? AppTheme.accent : AppTheme.textSecondary)
            .scaleEffect(bounce ? 1.2 : 1.0)
            .symbolEffect(.bounce, value: isSelected)
            .onChange(of: isSelected) { _, newValue in
                if newValue {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        bounce = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            bounce = false
                        }
                    }
                    HapticFeedback.selection()
                }
            }
    }
}

// MARK: - Premium Glow Card

struct PremiumGlowCard: ViewModifier {
    var glowColor: Color = AppTheme.accent
    var cornerRadius: CGFloat = 24
    @State private var glowIntensity: CGFloat = 0.3

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(AppTheme.surfaceLight)

                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    glowColor.opacity(0.6),
                                    glowColor.opacity(0.2),
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
                .shadow(color: glowColor.opacity(glowIntensity), radius: 20, x: 0, y: 10)
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    glowIntensity = 0.5
                }
            }
    }
}

extension View {
    func premiumGlowCard(glowColor: Color = AppTheme.accent, cornerRadius: CGFloat = 24) -> some View {
        modifier(PremiumGlowCard(glowColor: glowColor, cornerRadius: cornerRadius))
    }
}

// MARK: - Rounded Corner Shape

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
