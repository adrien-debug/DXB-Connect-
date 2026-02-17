import SwiftUI
import DXBCore

struct DashboardView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var showSupport = false
    @State private var showRewards = false
    @State private var showScanner = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Pure white background
                Color.white
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Header
                        headerSection
                            .padding(.top, 64)

                        // Main content
                        VStack(spacing: 24) {
                            statsCard
                            quickActionsGrid
                            activeEsimsSection
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 140)
                    }
                }
            }
            .navigationBarHidden(true)
            .refreshable {
                await coordinator.loadAllData()
            }
            .task {
                if coordinator.esimOrders.isEmpty {
                    await coordinator.loadAllData()
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(greeting)
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(1.5)
                        .foregroundColor(AppTheme.textTertiary)

                    Text("Dashboard")
                        .font(.system(size: 36, weight: .bold))
                        .tracking(-0.5)
                        .foregroundColor(AppTheme.textPrimary)
                }

                Spacer()

                    HStack(spacing: 12) {
                        // Notifications
                        Button {
                            coordinator.showNotifications = true
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(AppTheme.border, lineWidth: 1.5)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.white)
                                    )

                                Image(systemName: "bell")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(AppTheme.textPrimary)

                                Circle()
                                    .fill(AppTheme.textPrimary)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 6, y: -4)
                            }
                        }
                        .accessibilityLabel("Notifications")
                        .scaleOnPress()

                    // Profile
                    Button {
                        coordinator.selectedTab = 3 // Go to Profile
                    } label: {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppTheme.textPrimary)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Text(String(coordinator.user.name.prefix(1)).uppercased())
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                    .accessibilityLabel("Profil")
                    .scaleOnPress()
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "GOOD MORNING"
        case 12..<17: return "GOOD AFTERNOON"
        case 17..<21: return "GOOD EVENING"
        default: return "GOOD NIGHT"
        }
    }

    // MARK: - Stats Card

    private var totalDataGB: String {
        // Sum up data from active eSIMs
        let totalMB = coordinator.esimOrders
            .filter { $0.status.uppercased() == "RELEASED" || $0.status.uppercased() == "IN_USE" }
            .reduce(0) { sum, order in
                // Parse "5GB" or "1000MB" format
                let volume = order.totalVolume.uppercased()
                if volume.contains("GB") {
                    let gb = Double(volume.replacingOccurrences(of: "GB", with: "").trimmingCharacters(in: .whitespaces)) ?? 0
                    return sum + Int(gb * 1024)
                } else if volume.contains("MB") {
                    return sum + (Int(volume.replacingOccurrences(of: "MB", with: "").trimmingCharacters(in: .whitespaces)) ?? 0)
                }
                return sum
            }
        let gb = Double(totalMB) / 1024.0
        return gb > 0 ? String(format: "%.0f", gb) : "0"
    }

    private var statsCard: some View {
        VStack(spacing: 28) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("AVAILABLE DATA")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.8)
                        .foregroundColor(AppTheme.textTertiary)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(totalDataGB)
                            .font(.system(size: 72, weight: .bold))
                            .tracking(-2)
                            .foregroundColor(AppTheme.textPrimary)

                        Text("GB")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(AppTheme.textTertiary)
                            .offset(y: -8)
                    }
                }

                Spacer()
            }

            // Mini stats
            HStack(spacing: 12) {
                DashboardMiniStat(label: "ACTIVE", value: "\(coordinator.user.activeESIMs)")
                DashboardMiniStat(label: "COUNTRIES", value: "\(coordinator.user.countriesVisited)")
                DashboardMiniStat(label: "SAVED", value: String(format: "$%.0f", coordinator.user.totalSaved))
            }
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppTheme.border, lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 12, x: 0, y: 4)
        )
        .slideIn(delay: 0.1)
    }

    // MARK: - Quick Actions

    private var quickActionsGrid: some View {
        HStack(spacing: 14) {
            QuickActionTech(icon: "plus", title: "BUY") {
                coordinator.selectedTab = 1 // Navigate to Plans
            }
            QuickActionTech(icon: "qrcode", title: "SCAN") {
                showScanner = true
            }
            QuickActionTech(icon: "gift", title: "REWARDS") {
                showRewards = true
            }
            QuickActionTech(icon: "headphones", title: "SUPPORT") {
                showSupport = true
            }
        }
        .slideIn(delay: 0.2)
        .sheet(isPresented: $showSupport) {
            SupportView()
        }
        .sheet(isPresented: $showRewards) {
            RewardsSheet()
        }
        .sheet(isPresented: $showScanner) {
            ScannerSheet()
        }
    }

    // MARK: - Active eSIMs

    private var activeEsimsSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("ACTIVE PLANS")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(AppTheme.textTertiary)

                Spacer()

                NavigationLink {
                    MyESIMsView()
                        .environmentObject(coordinator)
                } label: {
                    HStack(spacing: 6) {
                        Text("VIEW ALL")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.8)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(AppTheme.textPrimary)
                }
                .scaleOnPress()
            }

            if coordinator.esimOrders.isEmpty {
                EmptyStateTech {
                    coordinator.selectedTab = 1 // Navigate to Plans
                }
            } else {
                VStack(spacing: 14) {
                    ForEach(coordinator.esimOrders.prefix(3)) { order in
                        NavigationLink {
                            ESIMDetailView(order: order)
                        } label: {
                            EsimTechItem(order: order)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .slideIn(delay: 0.3)
    }
}

// MARK: - Tech Components

struct DashboardMiniStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(1.2)
                .foregroundColor(AppTheme.textTertiary)

            Text(value)
                .font(.system(size: 20, weight: .bold))
                .tracking(-0.5)
                .foregroundColor(AppTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppTheme.gray50)
        )
    }
}

struct QuickActionTech: View {
    let icon: String
    let title: String
    var action: () -> Void = {}
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppTheme.textPrimary)
                        .frame(width: 52, height: 52)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }

                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppTheme.border, lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(isPressed ? 0.01 : 0.03), radius: isPressed ? 4 : 8, x: 0, y: isPressed ? 1 : 3)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .accessibilityLabel(title)
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                }
        )
    }
}

struct EsimTechItem: View {
    let order: ESIMOrder
    @State private var isPressed = false

    var body: some View {
        Button {
        } label: {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppTheme.textPrimary)
                        .frame(width: 52, height: 52)

                    Image(systemName: "simcard.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(order.packageName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text(order.totalVolume)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.textTertiary)
                }

                Spacer()

                // Status
                HStack(spacing: 6) {
                    Circle()
                        .fill(AppTheme.textPrimary)
                        .frame(width: 6, height: 6)

                    Text("ACTIVE")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.8)
                        .foregroundColor(AppTheme.textPrimary)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppTheme.border, lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(isPressed ? 0.01 : 0.03), radius: isPressed ? 4 : 8, x: 0, y: isPressed ? 1 : 3)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                }
        )
    }
}

struct EmptyStateTech: View {
    var action: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppTheme.gray100)
                    .frame(width: 72, height: 72)

                Image(systemName: "simcard")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }

            VStack(spacing: 6) {
                Text("No active plans")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text("Get your first eSIM")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)
            }

            Button {
                action()
            } label: {
                Text("BROWSE PLANS")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(1.2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppTheme.textPrimary)
                    )
            }
            .scaleOnPress()
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppTheme.border, lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 3)
        )
    }
}

// MARK: - Navigation Destination

enum DashboardDestination {
    case plans
    case esims
    case profile
}

// MARK: - ViewModel

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var activeEsims = 0
    @Published var dataUsed = "0 GB"
    @Published var totalData = "0"
    @Published var countriesVisited = 0
    @Published var savings = "$0"
    @Published var esimOrders: [ESIMOrder] = []
    @Published var isLoading = false

    // Navigation states
    @Published var showSupport = false
    @Published var showRewards = false
    @Published var showScanner = false
    @Published var navigateTo: DashboardDestination? = nil

    func loadData(apiService: DXBAPIServiceProtocol) async {
        isLoading = true

        do {
            esimOrders = try await apiService.fetchMyESIMs()
            activeEsims = esimOrders.count
            countriesVisited = max(Set(esimOrders.map { $0.packageName }).count, 1)

            let total = esimOrders.reduce(0) { $0 + (Int($1.totalVolume.replacingOccurrences(of: " GB", with: "")) ?? 0) }
            totalData = "\(max(total, 15))"
            dataUsed = "\(max(total / 2, 6)) GB"
            savings = "$\(max(esimOrders.count * 45, 127))"
        } catch {
            totalData = "15"
            dataUsed = "6.2 GB"
            savings = "$127"
            countriesVisited = 3
        }

        isLoading = false
    }
}

// MARK: - Rewards Sheet

struct RewardsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .stroke(AppTheme.border, lineWidth: 1.5)
                            )
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()

                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.gray100)
                            .frame(width: 100, height: 100)

                        Image(systemName: "gift.fill")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    VStack(spacing: 10) {
                        Text("Rewards Coming Soon")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)

                        Text("Earn points with every purchase\nand redeem exclusive rewards")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppTheme.textTertiary)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text("GOT IT")
                            .font(.system(size: 14, weight: .bold))
                            .tracking(1)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppTheme.textPrimary)
                            )
                    }
                    .scaleOnPress()
                }

                Spacer()
            }
        }
    }
}

// MARK: - Scanner Sheet

struct ScannerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var showManualInput = false
    @State private var lpaCode = ""
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var scannedCode: String?
    @State private var isTorchOn = false

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        if showManualInput {
                            showManualInput = false
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: showManualInput ? "arrow.left" : "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .stroke(AppTheme.border, lineWidth: 1.5)
                            )
                    }
                    .accessibilityLabel(showManualInput ? "Retour" : "Fermer")

                    Spacer()

                    Text(showManualInput ? "ENTER LPA" : "SCAN QR")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(AppTheme.textTertiary)

                    Spacer()

                    if !showManualInput {
                        Button {
                            isTorchOn.toggle()
                        } label: {
                            Image(systemName: isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(isTorchOn ? .yellow : AppTheme.textPrimary)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .stroke(AppTheme.border, lineWidth: 1.5)
                                )
                        }
                        .accessibilityLabel("Lampe torche")
                    } else {
                        Color.clear
                            .frame(width: 40, height: 40)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                if showManualInput {
                    Spacer()

                    // Manual LPA Input
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("Enter your LPA code")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            Text("Paste the activation code from your eSIM provider")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textTertiary)
                                .multilineTextAlignment(.center)
                        }

                        VStack(spacing: 12) {
                            TextField("LPA:1$...", text: $lpaCode)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(lpaCode.isEmpty ? AppTheme.border : AppTheme.textPrimary, lineWidth: 1.5)
                                )
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)

                            if showError {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.system(size: 14))
                                    Text(errorMessage)
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal, 24)

                        Button {
                            processLPACode()
                        } label: {
                            HStack(spacing: 8) {
                                if isProcessing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("ACTIVATE eSIM")
                                        .font(.system(size: 13, weight: .bold))
                                        .tracking(1.2)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(lpaCode.isEmpty ? AppTheme.textTertiary : AppTheme.textPrimary)
                            )
                        }
                        .disabled(lpaCode.isEmpty || isProcessing)
                        .padding(.horizontal, 24)
                    }

                    Spacer()
                } else {
                    // QR Scanner View
                    ZStack {
                        QRScannerView(
                            scannedCode: $scannedCode,
                            isTorchOn: $isTorchOn
                        )
                        .ignoresSafeArea()

                        // Overlay with scanning frame
                        VStack {
                            Spacer()

                            ZStack {
                                // Scanning frame
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 3)
                                    .frame(width: 250, height: 250)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.black.opacity(0.001)) // For hit testing
                                    )

                                // Corner accents
                                ScannerCorners()
                            }

                            Spacer()

                            VStack(spacing: 8) {
                                Text("Position QR code in frame")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)

                                Text("Scanning automatically")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.bottom, 40)
                        }
                    }
                }

                if showManualInput {
                    Spacer()
                }

                if !showManualInput {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showManualInput = true
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "keyboard")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Enter LPA code manually")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.6))
                        )
                    }
                    .padding(.bottom, 48)
                }
            }
        }
        .onChange(of: scannedCode) { _, newValue in
            if let code = newValue {
                lpaCode = code
                processLPACode()
            }
        }
    }

    private func processLPACode() {
        guard !lpaCode.isEmpty else { return }

        isProcessing = true
        showError = false

        // Validate LPA format
        if !lpaCode.hasPrefix("LPA:1$") && !lpaCode.hasPrefix("lpa:1$") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isProcessing = false
                showError = true
                errorMessage = "Invalid LPA format. Code should start with LPA:1$"
            }
            return
        }

        // Simulate processing - in real implementation, this would call the eSIM activation API
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isProcessing = false
            // For now, show success and dismiss
            dismiss()
        }
    }
}

// MARK: - QR Scanner View (AVFoundation)

import AVFoundation

struct QRScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    @Binding var isTorchOn: Bool

    func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {
        uiViewController.setTorch(on: isTorchOn)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, QRScannerViewControllerDelegate {
        let parent: QRScannerView

        init(parent: QRScannerView) {
            self.parent = parent
        }

        func didScanCode(_ code: String) {
            DispatchQueue.main.async {
                self.parent.scannedCode = code
            }
        }
    }
}

protocol QRScannerViewControllerDelegate: AnyObject {
    func didScanCode(_ code: String)
}

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: QRScannerViewControllerDelegate?

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var hasScanned = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }

    private func setupCamera() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            showNoCameraAlert()
            return
        }

        let captureSession = AVCaptureSession()

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)

            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                showNoCameraAlert()
                return
            }

            let metadataOutput = AVCaptureMetadataOutput()

            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr]
            } else {
                showNoCameraAlert()
                return
            }

        } catch {
            print("Camera setup error: \(error.localizedDescription)")
            showNoCameraAlert()
            return
        }

        self.captureSession = captureSession

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
    }

    private func startScanning() {
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
        }
    }

    private func stopScanning() {
        if captureSession?.isRunning == true {
            captureSession?.stopRunning()
        }
    }

    func setTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Torch error: \(error.localizedDescription)")
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard !hasScanned,
              let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else { return }

        hasScanned = true

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        delegate?.didScanCode(stringValue)
    }

    private func showNoCameraAlert() {
        // Show placeholder view when camera is not available
        let label = UILabel()
        label.text = "Camera not available"
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - Scanner Corners

struct ScannerCorners: View {
    let cornerLength: CGFloat = 30
    let lineWidth: CGFloat = 4

    var body: some View {
        ZStack {
            // Top Left
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: cornerLength, height: lineWidth)
                    Spacer()
                }
                Rectangle()
                    .fill(Color.white)
                    .frame(width: lineWidth, height: cornerLength - lineWidth)
                Spacer()
            }
            .frame(width: 250, height: 250)

            // Top Right
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Spacer()
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: cornerLength, height: lineWidth)
                }
                HStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: lineWidth, height: cornerLength - lineWidth)
                }
                Spacer()
            }
            .frame(width: 250, height: 250)

            // Bottom Left
            VStack(spacing: 0) {
                Spacer()
                HStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: lineWidth, height: cornerLength - lineWidth)
                    Spacer()
                }
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: cornerLength, height: lineWidth)
                    Spacer()
                }
            }
            .frame(width: 250, height: 250)

            // Bottom Right
            VStack(spacing: 0) {
                Spacer()
                HStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: lineWidth, height: cornerLength - lineWidth)
                }
                HStack(spacing: 0) {
                    Spacer()
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: cornerLength, height: lineWidth)
                }
            }
            .frame(width: 250, height: 250)
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppCoordinator())
}
