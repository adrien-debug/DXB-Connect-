import SwiftUI

// MARK: - GeoPoint (City coordinates in normalized Mercator 0-1)

struct GeoPoint: Identifiable {
    let id = UUID()
    let name: String
    let code: String
    let x: CGFloat
    let y: CGFloat

    static let cities: [GeoPoint] = [
        GeoPoint(name: "Dubai", code: "AE", x: 0.654, y: 0.365),
        GeoPoint(name: "London", code: "GB", x: 0.498, y: 0.235),
        GeoPoint(name: "New York", code: "US", x: 0.245, y: 0.295),
        GeoPoint(name: "Tokyo", code: "JP", x: 0.875, y: 0.320),
        GeoPoint(name: "Sydney", code: "AU", x: 0.905, y: 0.680),
        GeoPoint(name: "Paris", code: "FR", x: 0.508, y: 0.255),
        GeoPoint(name: "Singapore", code: "SG", x: 0.785, y: 0.505),
        GeoPoint(name: "Istanbul", code: "TR", x: 0.570, y: 0.290),
        GeoPoint(name: "Mumbai", code: "IN", x: 0.705, y: 0.395),
        GeoPoint(name: "São Paulo", code: "BR", x: 0.315, y: 0.625),
        GeoPoint(name: "Los Angeles", code: "US", x: 0.135, y: 0.330),
        GeoPoint(name: "Berlin", code: "DE", x: 0.530, y: 0.235),
        GeoPoint(name: "Seoul", code: "KR", x: 0.855, y: 0.310),
        GeoPoint(name: "Bangkok", code: "TH", x: 0.770, y: 0.430),
        GeoPoint(name: "Cairo", code: "EG", x: 0.575, y: 0.360)
    ]

    static var dubai: GeoPoint {
        cities.first { $0.code == "AE" }!
    }

    static func point(for code: String) -> GeoPoint? {
        cities.first { $0.code.uppercased() == code.uppercased() }
    }
}

// MARK: - World Map Outline Shape

struct WorldMapOutline: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Simplified continent outlines (~100 points total)
        // North America
        let northAmerica: [(CGFloat, CGFloat)] = [
            (0.05, 0.25), (0.08, 0.18), (0.12, 0.12), (0.18, 0.08),
            (0.25, 0.10), (0.30, 0.15), (0.32, 0.22), (0.28, 0.28),
            (0.22, 0.32), (0.18, 0.38), (0.15, 0.45), (0.20, 0.50),
            (0.28, 0.48), (0.32, 0.42), (0.30, 0.35), (0.25, 0.30),
            (0.18, 0.28), (0.10, 0.28), (0.05, 0.25)
        ]
        drawContinent(&path, points: northAmerica, in: rect)

        // South America
        let southAmerica: [(CGFloat, CGFloat)] = [
            (0.28, 0.52), (0.32, 0.55), (0.35, 0.62), (0.36, 0.70),
            (0.34, 0.78), (0.30, 0.85), (0.26, 0.88), (0.24, 0.82),
            (0.25, 0.74), (0.27, 0.66), (0.26, 0.58), (0.28, 0.52)
        ]
        drawContinent(&path, points: southAmerica, in: rect)

        // Europe
        let europe: [(CGFloat, CGFloat)] = [
            (0.46, 0.18), (0.50, 0.15), (0.55, 0.14), (0.58, 0.16),
            (0.60, 0.20), (0.58, 0.26), (0.54, 0.30), (0.50, 0.32),
            (0.46, 0.30), (0.44, 0.25), (0.46, 0.18)
        ]
        drawContinent(&path, points: europe, in: rect)

        // Africa
        let africa: [(CGFloat, CGFloat)] = [
            (0.48, 0.35), (0.52, 0.33), (0.58, 0.34), (0.62, 0.38),
            (0.64, 0.45), (0.65, 0.55), (0.62, 0.65), (0.56, 0.72),
            (0.50, 0.70), (0.46, 0.62), (0.45, 0.52), (0.46, 0.42),
            (0.48, 0.35)
        ]
        drawContinent(&path, points: africa, in: rect)

        // Asia
        let asia: [(CGFloat, CGFloat)] = [
            (0.60, 0.15), (0.68, 0.12), (0.78, 0.14), (0.88, 0.18),
            (0.92, 0.25), (0.90, 0.32), (0.85, 0.38), (0.78, 0.42),
            (0.72, 0.45), (0.68, 0.42), (0.65, 0.36), (0.62, 0.28),
            (0.60, 0.20), (0.60, 0.15)
        ]
        drawContinent(&path, points: asia, in: rect)

        // Australia
        let australia: [(CGFloat, CGFloat)] = [
            (0.82, 0.62), (0.88, 0.60), (0.94, 0.64), (0.95, 0.72),
            (0.92, 0.78), (0.86, 0.80), (0.80, 0.76), (0.78, 0.70),
            (0.80, 0.65), (0.82, 0.62)
        ]
        drawContinent(&path, points: australia, in: rect)

        return path
    }

    private func drawContinent(_ path: inout Path, points: [(CGFloat, CGFloat)], in rect: CGRect) {
        guard let first = points.first else { return }
        path.move(to: CGPoint(x: first.0 * rect.width, y: first.1 * rect.height))
        for point in points.dropFirst() {
            path.addLine(to: CGPoint(x: point.0 * rect.width, y: point.1 * rect.height))
        }
        path.closeSubpath()
    }
}

// MARK: - World Map View

struct WorldMapView: View {
    var highlightedCodes: [String] = []
    var showConnections: Bool = false
    var accentDots: Bool = true
    var connectionCodes: [String] = []
    var strokeColor: Color = AppTheme.anthracite
    var strokeOpacity: Double = 0.08
    var dotColor: Color = AppTheme.accent
    var showDubaiPulse: Bool = true

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Map outline
                WorldMapOutline()
                    .stroke(strokeColor.opacity(strokeOpacity), lineWidth: 0.8)

                // Connection lines from Dubai
                if showConnections {
                    ForEach(connectionCodes, id: \.self) { code in
                        if let destination = GeoPoint.point(for: code) {
                            ConnectionLine(
                                from: CGPoint(
                                    x: GeoPoint.dubai.x * geo.size.width,
                                    y: GeoPoint.dubai.y * geo.size.height
                                ),
                                to: CGPoint(
                                    x: destination.x * geo.size.width,
                                    y: destination.y * geo.size.height
                                )
                            )
                        }
                    }
                }

                // City dots
                ForEach(GeoPoint.cities) { city in
                    let isHighlighted = highlightedCodes.contains(city.code) || city.code == "AE"
                    let isConnection = connectionCodes.contains(city.code)

                    if isHighlighted || isConnection || accentDots {
                        Circle()
                            .fill(isHighlighted || city.code == "AE" ? dotColor : strokeColor.opacity(0.3))
                            .frame(width: isHighlighted ? 6 : 4, height: isHighlighted ? 6 : 4)
                            .position(
                                x: city.x * geo.size.width,
                                y: city.y * geo.size.height
                            )
                    }
                }

                // Dubai pulsing dot
                if showDubaiPulse {
                    PulsingDot(color: dotColor, size: 8)
                        .position(
                            x: GeoPoint.dubai.x * geo.size.width,
                            y: GeoPoint.dubai.y * geo.size.height
                        )
                }
            }
        }
    }
}

// MARK: - Connection Line (Animated dashed path)

struct ConnectionLine: View {
    let from: CGPoint
    let to: CGPoint
    var color: Color = AppTheme.accent
    var lineWidth: CGFloat = 1

    @State private var dashPhase: CGFloat = 0

    var body: some View {
        Path { path in
            path.move(to: from)

            // Curved line (quadratic bezier)
            let midX = (from.x + to.x) / 2
            let midY = min(from.y, to.y) - abs(to.x - from.x) * 0.15
            let control = CGPoint(x: midX, y: midY)
            path.addQuadCurve(to: to, control: control)
        }
        .stroke(
            color,
            style: StrokeStyle(
                lineWidth: lineWidth,
                lineCap: .round,
                dash: [6, 4],
                dashPhase: dashPhase
            )
        )
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                dashPhase = -20
            }
        }
    }
}

// MARK: - Pulsing Dot

struct PulsingDot: View {
    var color: Color = AppTheme.accent
    var size: CGFloat = 8

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Outer pulse ring
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: size * 1.8, height: size * 1.8)
                .scaleEffect(isAnimating ? 1.4 : 1.0)
                .opacity(isAnimating ? 0 : 0.6)

            // Core dot
            Circle()
                .fill(color)
                .frame(width: size, height: size)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Signal Rings (Radar/ping effect)

struct SignalRings: View {
    var color: Color = AppTheme.accent
    var size: CGFloat = 100

    @State private var ring1Scale: CGFloat = 0.3
    @State private var ring2Scale: CGFloat = 0.3
    @State private var ring3Scale: CGFloat = 0.3
    @State private var ring1Opacity: Double = 0.8
    @State private var ring2Opacity: Double = 0.8
    @State private var ring3Opacity: Double = 0.8

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(ring3Opacity), lineWidth: 1.5)
                .frame(width: size, height: size)
                .scaleEffect(ring3Scale)

            Circle()
                .stroke(color.opacity(ring2Opacity), lineWidth: 1.5)
                .frame(width: size * 0.7, height: size * 0.7)
                .scaleEffect(ring2Scale)

            Circle()
                .stroke(color.opacity(ring1Opacity), lineWidth: 1.5)
                .frame(width: size * 0.4, height: size * 0.4)
                .scaleEffect(ring1Scale)
        }
        .onAppear {
            // Ring 1
            withAnimation(.easeOut(duration: 3).repeatForever(autoreverses: false)) {
                ring1Scale = 2.5
                ring1Opacity = 0
            }
            // Ring 2 (delayed)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeOut(duration: 3).repeatForever(autoreverses: false)) {
                    ring2Scale = 2.5
                    ring2Opacity = 0
                }
            }
            // Ring 3 (more delayed)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeOut(duration: 3).repeatForever(autoreverses: false)) {
                    ring3Scale = 2.5
                    ring3Opacity = 0
                }
            }
        }
    }
}

// MARK: - Radial Gauge

struct RadialGauge: View {
    var progress: Double // 0.0 to 1.0
    var size: CGFloat = 80
    var trackColor: Color = AppTheme.gray100
    var fillColor: Color = AppTheme.accent
    var lineWidth: CGFloat = 6
    var valueText: String = ""
    var unitText: String = ""

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)
                .frame(width: size, height: size)

            // Fill
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    fillColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            // Center text
            VStack(spacing: 2) {
                Text(valueText)
                    .font(.system(size: size * 0.28, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)

                if !unitText.isEmpty {
                    Text(unitText)
                        .font(.system(size: size * 0.12, weight: .bold))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
    }
}

// MARK: - Tech Grid Pattern

struct TechGridPattern: View {
    var dotSize: CGFloat = 2
    var spacing: CGFloat = 20
    var color: Color = AppTheme.anthracite
    var opacity: Double = 0.04

    var body: some View {
        Canvas { context, size in
            let columns = Int(size.width / spacing)
            let rows = Int(size.height / spacing)

            for row in 0...rows {
                for col in 0...columns {
                    let x = CGFloat(col) * spacing
                    let y = CGFloat(row) * spacing
                    let rect = CGRect(x: x - dotSize/2, y: y - dotSize/2, width: dotSize, height: dotSize)
                    context.fill(Circle().path(in: rect), with: .color(color.opacity(opacity)))
                }
            }
        }
    }
}

// MARK: - Animated Scan Line (for QR overlay)

struct AnimatedScanLine: View {
    var color: Color = AppTheme.accent
    var height: CGFloat = 2

    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, color.opacity(0.6), color, color.opacity(0.6), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: height)
                .offset(y: offset)
                .onAppear {
                    offset = 0
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        offset = geo.size.height - height
                    }
                }
        }
    }
}

// MARK: - World Map View (Dark variant for headers)

struct WorldMapDarkView: View {
    var highlightedCodes: [String] = []
    var showConnections: Bool = false
    var connectionCodes: [String] = []
    var showDubaiPulse: Bool = true

    var body: some View {
        WorldMapView(
            highlightedCodes: highlightedCodes,
            showConnections: showConnections,
            accentDots: true,
            connectionCodes: connectionCodes,
            strokeColor: AppTheme.accent,
            strokeOpacity: 0.15,
            dotColor: AppTheme.accent,
            showDubaiPulse: showDubaiPulse
        )
    }
}

// MARK: - Preview

#Preview("TechGraphics") {
    ScrollView {
        VStack(spacing: 40) {
            // World Map
            WorldMapView(
                highlightedCodes: ["GB", "US", "JP"],
                showConnections: true,
                connectionCodes: ["GB", "US", "JP", "SG", "FR", "AU"]
            )
            .frame(height: 200)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding()

            // Signal Rings
            SignalRings(color: AppTheme.accent, size: 100)
                .frame(width: 150, height: 150)

            // Radial Gauge
            RadialGauge(
                progress: 0.75,
                size: 100,
                valueText: "7.5",
                unitText: "GB"
            )

            // Pulsing Dot
            PulsingDot(color: AppTheme.accent, size: 12)
                .frame(width: 50, height: 50)

            // Tech Grid
            TechGridPattern()
                .frame(height: 100)
                .background(Color.white)
        }
        .padding()
    }
    .background(AppTheme.backgroundSecondary)
}
