import SwiftUI

// MARK: - Pulse Design System
// Dark-only fintech aesthetic: #0A0A0A background, #141414 cards, #BAFF39 lime accent

// MARK: - Colors

enum AppColors {
    // Accent
    static let accent = Color(hex: "BAFF39")
    static let accentLight = Color(hex: "D4FF85")
    static let accentSoft = Color(hex: "EDFFC4")
    static let brandGray = Color(hex: "6E6E6E")
    static let white = Color(hex: "FFFFFF")

    // Semantic
    static let success = Color(hex: "22C55E")
    static let warning = Color(hex: "F59E0B")
    static let error = Color(hex: "EF4444")
    static let info = Color(hex: "3B82F6")

    // Pulse Dark-Only Palette
    static let background = Color(hex: "0A0A0A")
    static let backgroundSecondary = Color(hex: "111111")
    static let surface = Color(hex: "141414")
    static let surfaceSecondary = Color(hex: "1A1A1A")
    static let surfaceElevated = Color(hex: "1E1E1E")

    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "808080")
    static let textTertiary = Color(hex: "4A4A4A")
    static let textMuted = Color(hex: "333333")

    static let border = Color(hex: "1E1E1E")
    static let borderLight = Color(hex: "2A2A2A")

    // Chrome palette
    static let chromeLight = Color(hex: "3A3A3A")
    static let chromeMid = Color(hex: "2A2A2A")
    static let chromeDark = Color(hex: "1A1A1A")
    static let chromeHighlight = Color(hex: "4A4A4A")
    static let chromeBorder = Color(hex: "444444")
    static let chromeSheen = Color.white.opacity(0.06)

    // Legacy mapping
    static let navy = Color(hex: "0A0A0A")
    static let navyLight = Color(hex: "141414")
}

// MARK: - Typography

enum AppFonts {
    static func heroAmount() -> Font { .system(size: 48, weight: .bold, design: .rounded) }
    static func detailAmount() -> Font { .system(size: 40, weight: .bold, design: .rounded) }
    static func largeTitle() -> Font { .system(size: 28, weight: .bold, design: .rounded) }
    static func sectionTitle() -> Font { .system(size: 22, weight: .semibold, design: .rounded) }
    static func cardTitle() -> Font { .system(size: 20, weight: .semibold, design: .rounded) }
    static func cardAmount() -> Font { .system(size: 18, weight: .semibold, design: .rounded) }
    static func body() -> Font { .system(size: 15, weight: .regular) }
    static func bodyMedium() -> Font { .system(size: 15, weight: .medium) }
    static func caption() -> Font { .system(size: 13, weight: .regular) }
    static func small() -> Font { .system(size: 11, weight: .regular) }
    static func navTitle() -> Font { .system(size: 12, weight: .bold) }
    static func tabLabel() -> Font { .system(size: 14, weight: .medium) }
    static func button() -> Font { .system(size: 14, weight: .bold) }
    static func label() -> Font { .system(size: 10, weight: .bold) }

    static let systemHero = Font.system(size: 48, weight: .bold, design: .rounded)
    static let systemBody = Font.system(size: 15, weight: .regular)
}

// MARK: - Spacing

enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let base: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
}

// MARK: - Border Radius

enum AppRadius {
    static let xs: CGFloat = 6
    static let sm: CGFloat = 10
    static let md: CGFloat = 14
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 28
    static let full: CGFloat = 9999
}

// MARK: - Color Hex Init

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

// MARK: - Legacy Compatibility

enum AppTheme {
    static let accent = AppColors.accent
    static let background = AppColors.background
    static let card = AppColors.surface
    static let cardBorder = AppColors.border
    static let textPrimary = AppColors.textPrimary
    static let textSecondary = AppColors.textSecondary
    static let textTertiary = AppColors.textTertiary
    static let textMuted = AppColors.textMuted

    static let success = AppColors.success
    static let warning = AppColors.warning
    static let error = AppColors.error
    static let info = AppColors.info

    static let surfaceElevated = AppColors.surfaceElevated
    static let surfacePressed = Color.white.opacity(0.03)

    static let gold = AppColors.accent
    static let goldLight = AppColors.accentLight
    static let goldDeep = AppColors.navy
    static let goldDark = AppColors.navyLight

    static func tierColor(_ tier: String) -> Color {
        switch tier.lowercased() {
        case "privilege": return AppColors.chromeLight
        case "elite":     return AppColors.accent
        case "black":     return AppColors.white
        default:          return textSecondary
        }
    }

    static func tierIcon(_ tier: String) -> String {
        switch tier.lowercased() {
        case "privilege": return "shield.checkered"
        case "elite":     return "crown.fill"
        case "black":     return "diamond.fill"
        default:          return "person.fill"
        }
    }
}

enum GoldPalette {
    static let gold = AppColors.accent
    static let goldLight = AppColors.accentLight
    static let goldDeep = AppColors.navy
    static let goldDark = AppColors.navyLight
    static let goldMuted = AppColors.textMuted

    static var gradient: LinearGradient {
        LinearGradient(
            colors: [AppColors.accent, AppColors.accentLight],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var glowGradient: RadialGradient {
        RadialGradient(
            colors: [AppColors.accent.opacity(0.20), Color.clear],
            center: .center,
            startRadius: 20,
            endRadius: 120
        )
    }
}

// MARK: - Pulse Card Modifier

struct PulseCardModifier: ViewModifier {
    var padding: CGFloat = AppSpacing.lg
    var cornerRadius: CGFloat = AppRadius.lg
    var glow: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(AppColors.border, lineWidth: 0.5)
                    )
            )
            .shadow(
                color: glow ? AppColors.accent.opacity(0.06) : Color.black.opacity(0.15),
                radius: glow ? 20 : 8,
                x: 0, y: glow ? 8 : 4
            )
    }
}

struct BentoCardModifier: ViewModifier {
    var padding: CGFloat = AppSpacing.base
    var cornerRadius: CGFloat = AppRadius.lg

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(AppColors.border, lineWidth: 0.5)
                    )
            )
            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
    }
}

struct ChromeCardModifier: ViewModifier {
    var padding: CGFloat = AppSpacing.base
    var cornerRadius: CGFloat = AppRadius.lg
    var accentGlow: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: AppColors.chromeLight, location: 0),
                                    .init(color: AppColors.chromeDark, location: 0.45),
                                    .init(color: AppColors.chromeMid, location: 0.7),
                                    .init(color: AppColors.chromeLight.opacity(0.8), location: 1.0),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Top sheen highlight
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppColors.chromeSheen,
                                    Color.clear,
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )

                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    AppColors.chromeBorder,
                                    AppColors.chromeHighlight.opacity(0.3),
                                    AppColors.chromeBorder.opacity(0.6),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(
                color: accentGlow ? AppColors.accent.opacity(0.06) : Color.black.opacity(0.25),
                radius: accentGlow ? 16 : 8,
                x: 0, y: 4
            )
    }
}

extension View {
    func pulseCard(glow: Bool = false) -> some View {
        modifier(PulseCardModifier(glow: glow))
    }

    func bentoCard(padding: CGFloat = AppSpacing.base) -> some View {
        modifier(BentoCardModifier(padding: padding))
    }

    func chromeCard(padding: CGFloat = AppSpacing.base, accentGlow: Bool = false) -> some View {
        modifier(ChromeCardModifier(padding: padding, accentGlow: accentGlow))
    }

    // Legacy support
    func tokenCard() -> some View {
        modifier(PulseCardModifier())
    }

    func cleanCard(padding: CGFloat = AppSpacing.lg, cornerRadius: CGFloat = AppRadius.lg) -> some View {
        modifier(PulseCardModifier(padding: padding, cornerRadius: cornerRadius))
    }

    func glassCard(padding: CGFloat = AppSpacing.lg, cornerRadius: CGFloat = AppRadius.lg, goldAccent: Bool = false) -> some View {
        modifier(PulseCardModifier(padding: padding, cornerRadius: cornerRadius, glow: goldAccent))
    }

    func techCard(padding: CGFloat = AppSpacing.lg, cornerRadius: CGFloat = AppRadius.lg, goldAccent: Bool = false, showScanLine: Bool = false) -> some View {
        modifier(PulseCardModifier(padding: padding, cornerRadius: cornerRadius, glow: goldAccent))
    }

    func navyCard(padding: CGFloat = AppSpacing.lg, cornerRadius: CGFloat = AppRadius.lg) -> some View {
        modifier(PulseCardModifier(padding: padding, cornerRadius: cornerRadius))
    }
}

// MARK: - Button Styles

struct GoldButtonStyle: ButtonStyle {
    var isSmall = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: isSmall ? 14 : 16, weight: .bold))
            .foregroundStyle(.black)
            .padding(.horizontal, isSmall ? 20 : 28)
            .padding(.vertical, isSmall ? 12 : 16)
            .frame(maxWidth: isSmall ? nil : .infinity)
            .background(
                Capsule()
                    .fill(AppColors.accent)
            )
            .shadow(color: AppColors.accent.opacity(0.25), radius: 10, x: 0, y: 5)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

typealias PrimaryButtonStyle = GoldButtonStyle

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(AppColors.textPrimary)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(AppColors.surface)
                    .overlay(
                        Capsule()
                            .stroke(AppColors.borderLight, lineWidth: 0.5)
                    )
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

typealias GhostButtonStyle = SecondaryButtonStyle

// Keep old TokenCardStyle for any remaining references
struct TokenCardStyle: ViewModifier {
    var padding: CGFloat = AppSpacing.lg
    var cornerRadius: CGFloat = AppRadius.lg

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
            )
    }
}

// MARK: - Loading Overlay

struct LoadingOverlay: View {
    let message: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.60)
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.lg) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(AppColors.accent)

                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(AppSpacing.xxl)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(AppColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 5, height: 5)

            Text(text)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppColors.accent.opacity(0.08))
                    .frame(width: 80, height: 80)

                Image(systemName: icon)
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(AppColors.accent.opacity(0.8))
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 260)
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(PrimaryButtonStyle(isSmall: true))
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

// MARK: - Arc Progress

struct CleanArcProgress: View {
    let progress: Double
    var lineWidth: CGFloat = 10
    var size: CGFloat = 160

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColors.border, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    AngularGradient(
                        colors: [AppColors.accent, AppColors.accentLight],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: AppColors.accent.opacity(0.4), radius: 8, x: 0, y: 0)
                .animation(.easeInOut(duration: 0.8), value: progress)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Shimmer

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, Color.white.opacity(0.08), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: -geo.size.width + phase * geo.size.width * 2)
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Slide In Animation

struct SlideInModifier: ViewModifier {
    let delay: Double
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay), value: appeared)
            .onAppear { appeared = true }
    }
}

extension View {
    func slideIn(delay: Double = 0) -> some View {
        modifier(SlideInModifier(delay: delay))
    }
}

// MARK: - Scale On Press

struct ScaleOnPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension View {
    func scaleOnPress() -> some View {
        self.buttonStyle(ScaleOnPressStyle())
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

    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}

// MARK: - Pulse Background

struct PulseBackground: View {
    var showGlow: Bool = true

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            if showGlow {
                RadialGradient(
                    colors: [
                        AppColors.accent.opacity(0.04),
                        AppColors.accent.opacity(0.01),
                        Color.clear
                    ],
                    center: .top,
                    startRadius: 0,
                    endRadius: 400
                )
                .frame(height: 500)
                .offset(y: -150)
                .ignoresSafeArea()
            }
        }
    }
}

// MARK: - Pulse Section Header

struct PulseSectionHeader: View {
    let title: String
    var action: String?
    var onAction: (() -> Void)?

    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            if let action, let onAction {
                Button(action: onAction) {
                    HStack(spacing: 3) {
                        Text(action)
                            .font(.system(size: 12, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundColor(AppColors.accent)
                }
            }
        }
    }
}

// MARK: - Shared Helpers

enum ESIMStatusHelper {
    static func isActive(_ status: String) -> Bool {
        ["ENABLED", "IN_USE", "ACTIVE", "RELEASED"].contains(status.uppercased())
    }

    static func label(_ status: String) -> String {
        switch status.uppercased() {
        case "ENABLED", "IN_USE", "ACTIVE", "RELEASED": return "Active"
        case "DISABLED": return "Suspended"
        case "PENDING": return "Pending"
        default: return "Expired"
        }
    }

    static func color(_ status: String) -> Color {
        switch status.uppercased() {
        case "ENABLED", "IN_USE", "ACTIVE", "RELEASED": return AppColors.success
        case "PENDING": return AppColors.warning
        case "DISABLED": return AppColors.textTertiary
        default: return AppColors.error
        }
    }
}

enum CountryHelper {
    static func flag(for locationOrCode: String) -> String {
        if locationOrCode.count == 2 {
            return flagFromCode(locationOrCode)
        }
        return flagFromName(locationOrCode)
    }

    static func flagFromCode(_ code: String) -> String {
        guard code.count == 2 else { return "🌍" }
        let base: UInt32 = 127397
        var flag = ""
        for scalar in code.uppercased().unicodeScalars {
            if let unicode = UnicodeScalar(base + scalar.value) {
                flag.append(String(unicode))
            }
        }
        return flag.isEmpty ? "🌍" : flag
    }

    static func flagFromName(_ name: String) -> String {
        let n = name.lowercased()
        let map: [(keys: [String], emoji: String)] = [
            (["arab", "uae", "emirates", "dubai"], "🇦🇪"),
            (["turkey", "türkiye"], "🇹🇷"),
            (["europe"], "🇪🇺"),
            (["united states", "usa", "u.s."], "🇺🇸"),
            (["japan"], "🇯🇵"),
            (["united kingdom", "uk", "britain"], "🇬🇧"),
            (["france"], "🇫🇷"),
            (["germany"], "🇩🇪"),
            (["thai"], "🇹🇭"),
            (["singapore"], "🇸🇬"),
            (["italy"], "🇮🇹"),
            (["spain"], "🇪🇸"),
            (["australia"], "🇦🇺"),
            (["canada"], "🇨🇦"),
            (["brazil"], "🇧🇷"),
            (["india"], "🇮🇳"),
            (["china"], "🇨🇳"),
            (["south korea", "korea"], "🇰🇷"),
            (["mexico"], "🇲🇽"),
            (["indonesia"], "🇮🇩"),
            (["malaysia"], "🇲🇾"),
            (["philippines"], "🇵🇭"),
            (["vietnam"], "🇻🇳"),
            (["saudi", "ksa"], "🇸🇦"),
            (["egypt"], "🇪🇬"),
            (["south africa"], "🇿🇦"),
            (["nigeria"], "🇳🇬"),
            (["kenya"], "🇰🇪"),
            (["morocco"], "🇲🇦"),
            (["netherlands", "holland"], "🇳🇱"),
            (["belgium"], "🇧🇪"),
            (["switzerland"], "🇨🇭"),
            (["austria"], "🇦🇹"),
            (["portugal"], "🇵🇹"),
            (["greece"], "🇬🇷"),
            (["sweden"], "🇸🇪"),
            (["norway"], "🇳🇴"),
            (["denmark"], "🇩🇰"),
            (["finland"], "🇫🇮"),
            (["poland"], "🇵🇱"),
            (["czech", "czechia"], "🇨🇿"),
            (["ireland"], "🇮🇪"),
            (["russia"], "🇷🇺"),
            (["ukraine"], "🇺🇦"),
            (["israel"], "🇮🇱"),
            (["qatar"], "🇶🇦"),
            (["bahrain"], "🇧🇭"),
            (["kuwait"], "🇰🇼"),
            (["oman"], "🇴🇲"),
            (["jordan"], "🇯🇴"),
            (["lebanon"], "🇱🇧"),
            (["pakistan"], "🇵🇰"),
            (["bangladesh"], "🇧🇩"),
            (["sri lanka"], "🇱🇰"),
            (["nepal"], "🇳🇵"),
            (["myanmar"], "🇲🇲"),
            (["cambodia"], "🇰🇭"),
            (["laos"], "🇱🇦"),
            (["taiwan"], "🇹🇼"),
            (["hong kong"], "🇭🇰"),
            (["macao", "macau"], "🇲🇴"),
            (["mongolia"], "🇲🇳"),
            (["new zealand"], "🇳🇿"),
            (["fiji"], "🇫🇯"),
            (["argentina"], "🇦🇷"),
            (["colombia"], "🇨🇴"),
            (["chile"], "🇨🇱"),
            (["peru"], "🇵🇪"),
            (["ecuador"], "🇪🇨"),
            (["venezuela"], "🇻🇪"),
            (["costa rica"], "🇨🇷"),
            (["panama"], "🇵🇦"),
            (["dominican"], "🇩🇴"),
            (["jamaica"], "🇯🇲"),
            (["cuba"], "🇨🇺"),
            (["puerto rico"], "🇵🇷"),
            (["romania"], "🇷🇴"),
            (["hungary"], "🇭🇺"),
            (["croatia"], "🇭🇷"),
            (["bulgaria"], "🇧🇬"),
            (["serbia"], "🇷🇸"),
            (["slovakia"], "🇸🇰"),
            (["slovenia"], "🇸🇮"),
            (["estonia"], "🇪🇪"),
            (["latvia"], "🇱🇻"),
            (["lithuania"], "🇱🇹"),
            (["iceland"], "🇮🇸"),
            (["luxembourg"], "🇱🇺"),
            (["malta"], "🇲🇹"),
            (["cyprus"], "🇨🇾"),
            (["tunisia"], "🇹🇳"),
            (["algeria"], "🇩🇿"),
            (["ghana"], "🇬🇭"),
            (["tanzania"], "🇹🇿"),
            (["ethiopia"], "🇪🇹"),
            (["uganda"], "🇺🇬"),
            (["global"], "🌍"),
            (["asia"], "🌏"),
        ]
        for entry in map {
            for key in entry.keys {
                if n.contains(key) { return entry.emoji }
            }
        }
        return "🌐"
    }
}

enum DateFormatHelper {
    static func formatISO(_ raw: String, locale: String = "en_US") -> String {
        guard !raw.isEmpty else { return "--" }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = iso.date(from: raw) ?? ISO8601DateFormatter().date(from: raw)
        guard let date else { return String(raw.prefix(10)) }
        return format(date, locale: locale)
    }

    static func format(_ date: Date, locale: String = "en_US") -> String {
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy"
        df.locale = Locale(identifier: locale)
        return df.string(from: date)
    }
}

// MARK: - Pulse Icon Button

struct PulseIconButton: View {
    let icon: String
    var badge: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(AppColors.surfaceSecondary)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle().stroke(AppColors.border, lineWidth: 0.5)
                    )

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 40, height: 40)

                if badge {
                    Circle()
                        .fill(AppColors.accent)
                        .frame(width: 8, height: 8)
                        .overlay(Circle().stroke(AppColors.background, lineWidth: 1.5))
                        .offset(x: -3, y: 3)
                }
            }
        }
    }
}
