import SwiftUI

// MARK: - Theme Mode Manager

enum AppearanceMode: String {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
}

// MARK: - Dynamic Theme with Dark Mode Support

struct AppTheme {
    // MARK: - Spacing Scale (Pulse Token System)

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
        static let xs: CGFloat = 6
        static let sm: CGFloat = 10
        static let md: CGFloat = 14
        static let lg: CGFloat = 18
        static let xl: CGFloat = 22
        static let xxl: CGFloat = 28
        static let full: CGFloat = 9999
    }

    // MARK: - Typography Presets

    enum Typography {
        static func display() -> Font { .system(size: 56, weight: .bold, design: .default) }
        static func heroAmount() -> Font { .system(size: 48, weight: .bold, design: .default) }
        static func detailAmount() -> Font { .system(size: 40, weight: .bold, design: .default) }
        static func headline() -> Font { .system(size: 32, weight: .bold, design: .default) }
        static func sectionTitle() -> Font { .system(size: 22, weight: .semibold) }
        static func cardAmount() -> Font { .system(size: 18, weight: .semibold) }
        static func bodyLarge() -> Font { .system(size: 17, weight: .regular) }
        static func body() -> Font { .system(size: 15, weight: .regular) }
        static func caption() -> Font { .system(size: 13, weight: .medium) }
        static func small() -> Font { .system(size: 11, weight: .medium) }
        static func navTitle() -> Font { .system(size: 12, weight: .bold) }
        static func tabLabel() -> Font { .system(size: 14, weight: .medium) }
        static func button() -> Font { .system(size: 15, weight: .semibold) }
        static func buttonSmall() -> Font { .system(size: 13, weight: .semibold) }
        static func label() -> Font { .system(size: 10, weight: .bold) }
        static func overline() -> Font { .system(size: 11, weight: .semibold) }
    }

    // MARK: - Deep Navy (replaces pure black in UI elements)

    static var anthracite: Color { Color(hex: "0F172A") }
    static var anthraciteLight: Color { Color(hex: "1E293B") }

    // MARK: - Accent Color (Lime — Pulse #CDFF00)

    static var accent: Color { adaptiveColor(light: "CDFF00", dark: "CDFF00") }
    static var accentLight: Color { adaptiveColor(light: "E8FF80", dark: "3A4A00") }
    static var accentSoft: Color { adaptiveColor(light: "F5FFD6", dark: "1A2000") }

    // MARK: - Primary colors

    static var primary: Color { adaptiveColor(light: "0F172A", dark: "F1F5F9") }
    static var primaryLight: Color { adaptiveColor(light: "334155", dark: "94A3B8") }
    static var primaryDark: Color { adaptiveColor(light: "020617", dark: "F8FAFC") }
    static var primarySoft: Color { adaptiveColor(light: "F1F5F9", dark: "1E293B") }

    // MARK: - Grayscale Spectrum (Slate)

    static var gray50: Color { adaptiveColor(light: "F8FAFC", dark: "0F172A") }
    static var gray100: Color { adaptiveColor(light: "F1F5F9", dark: "1E293B") }
    static var gray200: Color { adaptiveColor(light: "E2E8F0", dark: "334155") }
    static var gray300: Color { adaptiveColor(light: "CBD5E1", dark: "475569") }
    static var gray400: Color { adaptiveColor(light: "94A3B8", dark: "64748B") }
    static var gray500: Color { adaptiveColor(light: "64748B", dark: "94A3B8") }
    static var gray600: Color { adaptiveColor(light: "475569", dark: "CBD5E1") }
    static var gray700: Color { adaptiveColor(light: "334155", dark: "E2E8F0") }
    static var gray800: Color { adaptiveColor(light: "1E293B", dark: "F1F5F9") }
    static var gray900: Color { adaptiveColor(light: "0F172A", dark: "F8FAFC") }

    // MARK: - Semantic Colors

    static var success: Color { adaptiveColor(light: "16A34A", dark: "4ADE80") }
    static var successLight: Color { adaptiveColor(light: "F0FDF4", dark: "14532D") }
    static var warning: Color { adaptiveColor(light: "D97706", dark: "FBBF24") }
    static var warningLight: Color { adaptiveColor(light: "FFFBEB", dark: "451A03") }
    static var error: Color { adaptiveColor(light: "DC2626", dark: "F87171") }
    static var errorLight: Color { adaptiveColor(light: "FEF2F2", dark: "450A0A") }
    static var info: Color { adaptiveColor(light: "2563EB", dark: "60A5FA") }

    // MARK: - Backgrounds

    static var backgroundPrimary: Color { adaptiveColor(light: "FFFFFF", dark: "0C1425") }
    static var backgroundSecondary: Color { adaptiveColor(light: "F8FAFC", dark: "0F172A") }
    static var backgroundTertiary: Color { adaptiveColor(light: "F1F5F9", dark: "1E293B") }

    // MARK: - Surfaces

    static var surfaceLight: Color { adaptiveColor(light: "FFFFFF", dark: "0F172A") }
    static var surfaceMedium: Color { adaptiveColor(light: "F8FAFC", dark: "1E293B") }
    static var surfaceHeavy: Color { adaptiveColor(light: "F1F5F9", dark: "334155") }

    // MARK: - Text

    static var textPrimary: Color { adaptiveColor(light: "0F172A", dark: "F1F5F9") }
    static var textSecondary: Color { adaptiveColor(light: "475569", dark: "94A3B8") }
    static var textTertiary: Color { adaptiveColor(light: "94A3B8", dark: "64748B") }
    static var textMuted: Color { adaptiveColor(light: "CBD5E1", dark: "475569") }

    // MARK: - Borders

    static var border: Color { adaptiveColor(light: "E2E8F0", dark: "1E293B") }
    static var borderLight: Color { adaptiveColor(light: "F1F5F9", dark: "162032") }
    static var borderDark: Color { adaptiveColor(light: "CBD5E1", dark: "475569") }

    // MARK: - Gradient helpers

    static var accentGradientStart: Color { adaptiveColor(light: "CDFF00", dark: "CDFF00") }
    static var accentGradientEnd: Color { adaptiveColor(light: "B8F000", dark: "B8F000") }
    static var heroGradient: Color { backgroundPrimary }

    // MARK: - Glass surfaces

    static var glassLight: Color { adaptiveColor(light: "FFFFFF", dark: "0F172A") }
    static var glassMedium: Color { adaptiveColor(light: "FFFFFF", dark: "1E293B") }
    static var glassDark: Color { adaptiveColor(light: "F1F5F9", dark: "334155") }

    // Compatibility aliases
    static var brand: Color { accent }
    static var brandGradient: Color { accent }
    static var deepVioletGradient: Color { primary }
    static var lightVioletGradient: Color { backgroundPrimary }
    static var cardGradient: Color { backgroundPrimary }
    static var glassViolet: Color { backgroundPrimary }
    static var accent1: Color { accent }
    static var accent2: Color { adaptiveColor(light: "3F3F46", dark: "A1A1AA") }
    static var accent3: Color { adaptiveColor(light: "71717A", dark: "71717A") }
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
                    .fill(AppTheme.surfaceLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(AppTheme.border.opacity(0.6), lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                    .shadow(color: Color.black.opacity(0.03), radius: 16, x: 0, y: 8)
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
                    .fill(AppTheme.surfaceLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(AppTheme.border.opacity(0.5), lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.02), radius: 1, x: 0, y: 1)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                    .shadow(color: Color.black.opacity(0.02), radius: 20, x: 0, y: 10)
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
                    .fill(AppTheme.surfaceLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(AppTheme.border.opacity(0.5), lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.02), radius: 1, x: 0, y: 1)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    .shadow(color: Color.black.opacity(0.03), radius: 24, x: 0, y: 12)
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
            AppTheme.accent,
            AppTheme.accent.opacity(0.7),
            Color(hex: "1E3A5F"),
            Color(hex: "0A1628")
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
