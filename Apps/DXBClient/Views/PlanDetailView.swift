import SwiftUI
import DXBCore

struct PlanDetailView: View {
    let plan: Plan
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = PlanDetailViewModel()

    private var flagEmoji: String {
        let base: UInt32 = 127397
        var emoji = ""
        for scalar in plan.locationCode.uppercased().unicodeScalars {
            if let s = UnicodeScalar(base + scalar.value) {
                emoji.append(String(s))
            }
        }
        return emoji.isEmpty ? "🌍" : emoji
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundSecondary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav Bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(AppTheme.gray100))
                    }

                    Spacer()

                    Text("PLAN DETAILS")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(AppTheme.textSecondary)

                    Spacer()

                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Hero with world map background + connection line
                        ZStack {
                            // World map background
                            WorldMapView(
                                highlightedCodes: [plan.locationCode],
                                showConnections: true,
                                accentDots: false,
                                connectionCodes: [plan.locationCode],
                                strokeColor: AppTheme.anthracite,
                                strokeOpacity: 0.04,
                                dotColor: AppTheme.accent,
                                showDubaiPulse: true
                            )
                            .frame(height: 200)

                            VStack(spacing: 0) {
                                Text(flagEmoji)
                                    .font(.system(size: 72))
                                    .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
                                    .padding(.top, 24)
                                    .slideIn(delay: 0)

                                VStack(spacing: 8) {
                                    Text(plan.location)
                                        .font(.system(size: 30, weight: .bold))
                                        .tracking(-0.8)
                                        .foregroundColor(AppTheme.textPrimary)

                                    Text(plan.name)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(AppTheme.textTertiary)
                                }
                                .padding(.top, 16)
                                .slideIn(delay: 0.05)

                            }
                        }
                        .padding(.bottom, 20)

                        HStack(spacing: 0) {
                            VStack(spacing: 4) {
                                Text("\(plan.dataGB)")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                Text("GB")
                                    .font(.system(size: 12, weight: .bold))
                                    .opacity(0.6)
                            }
                            .frame(maxWidth: .infinity)

                            Rectangle()
                                .fill(Color(hex: "0F172A").opacity(0.12))
                                .frame(width: 1, height: 36)

                            VStack(spacing: 4) {
                                Text("\(plan.durationDays)")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                Text("days")
                                    .font(.system(size: 12, weight: .bold))
                                    .opacity(0.6)
                            }
                            .frame(maxWidth: .infinity)

                            Rectangle()
                                .fill(Color(hex: "0F172A").opacity(0.12))
                                .frame(width: 1, height: 36)

                            VStack(spacing: 4) {
                                Text(plan.priceUSD.formattedPrice)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                Text("one-time")
                                    .font(.system(size: 12, weight: .bold))
                                    .opacity(0.6)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .foregroundColor(Color(hex: "0F172A"))
                        .padding(.vertical, 22)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.xl)
                                .fill(AppTheme.accent)
                                .shadow(color: AppTheme.accent.opacity(0.3), radius: 16, x: 0, y: 6)
                        )
                        .padding(.horizontal, 20)
                        .slideIn(delay: 0.1)

                        Spacer().frame(height: 16)

                        HStack(spacing: 10) {
                            PlanSpecCard(icon: "arrow.down.circle.fill", value: "\(plan.dataGB)", unit: "GB", label: "Data")
                            PlanSpecCard(icon: "clock.fill", value: "\(plan.durationDays)", unit: "days", label: "Validity")
                            PlanSpecCard(icon: "bolt.fill", value: plan.speed, unit: "", label: "Speed")
                        }
                        .padding(.horizontal, 20)
                        .slideIn(delay: 0.15)

                        VStack(alignment: .leading, spacing: 20) {
                            Text("What's included")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            VStack(spacing: 0) {
                                IncludedFeatureRow(icon: "bolt.fill", text: "Instant activation — ready in seconds")
                                IncludedDivider()
                                IncludedFeatureRow(icon: "clock.fill", text: "24/7 priority support")
                                IncludedDivider()
                                IncludedFeatureRow(icon: "xmark.circle.fill", text: "No roaming fees, ever")
                                IncludedDivider()
                                IncludedFeatureRow(icon: "phone.fill", text: "Keep your existing number")
                                IncludedDivider()
                                IncludedFeatureRow(icon: "arrow.counterclockwise", text: "Money-back guarantee within 24h")
                            }
                        }
                        .padding(22)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(AppTheme.backgroundPrimary)
                                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .slideIn(delay: 0.2)

                        Spacer(minLength: 100)
                    }
                }

                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("TOTAL")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(AppTheme.textTertiary)

                            Text(plan.priceUSD.formattedPrice)
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        Button {
                            HapticFeedback.medium()
                            viewModel.showPaymentSheet = true
                        } label: {
                            HStack(spacing: 10) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(Color(hex: "0F172A"))
                                } else {
                                    Text("Continue")
                                        .font(.system(size: 17, weight: .semibold))
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .foregroundColor(Color(hex: "0F172A"))
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(AppTheme.accent)
                            )
                        }
                        .pulse(color: AppTheme.accent, radius: 18)
                        .disabled(viewModel.isLoading)
                        .scaleOnPress()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 36)
                    .background(
                        AppTheme.backgroundPrimary
                            .shadow(color: Color.black.opacity(0.08), radius: 16, y: -6)
                    )
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $viewModel.showSuccess) {
            PaymentSuccessView(plan: plan) {
                viewModel.showSuccess = false
                coordinator.selectedTab = 3
                dismiss()
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .sheet(isPresented: $viewModel.showPaymentSheet) {
            PaymentSheetView(
                plan: plan,
                onSuccess: {
                    viewModel.showPaymentSheet = false
                    viewModel.showSuccess = true
                    Task {
                        await coordinator.loadESIMs()
                    }
                },
                onCancel: {
                    viewModel.showPaymentSheet = false
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        }
    }
}

// MARK: - Plan Spec Items

struct PlanSpecCard: View {
    let icon: String
    let value: String
    let unit: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(AppTheme.accent)

            HStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)

                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.top, 3)
                }
            }

            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
                .foregroundColor(AppTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppTheme.backgroundPrimary)
                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
}

struct PlanSpecItem: View {
    let value: String
    let unit: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)

                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.top, 4)
                }
            }

            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .tracking(0.8)
                .foregroundColor(AppTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PlanSpecDivider: View {
    var body: some View {
        Rectangle()
            .fill(AppTheme.border.opacity(0.5))
            .frame(width: 0.5, height: 40)
    }
}

struct IncludedDivider: View {
    var body: some View {
        Rectangle()
            .fill(AppTheme.border.opacity(0.3))
            .frame(height: 0.5)
            .padding(.leading, 50)
            .padding(.vertical, 2)
    }
}

// MARK: - Feature Card

struct FeatureTechCard: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppTheme.accent.opacity(0.1))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.accent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundColor(AppTheme.textSecondary)

                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.backgroundPrimary)
                .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
        )
    }
}

// MARK: - Included Feature Row

struct IncludedFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(AppTheme.accent.opacity(0.1))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.accent)
                )

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
                .lineSpacing(2)

            Spacer()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 32)
                .foregroundColor(AppTheme.accent)

            Text(title)
                .foregroundColor(AppTheme.textSecondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.textPrimary)
        }
    }
}

// MARK: - ViewModel

@MainActor
final class PlanDetailViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showSuccess = false
    @Published var showError = false
    @Published var showPaymentSheet = false
    @Published var errorMessage = ""

    func purchase(plan: Plan, apiService: DXBAPIServiceProtocol) async {
        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await apiService.purchasePlan(planId: plan.id)
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    NavigationStack {
        PlanDetailView(plan: Plan(
            id: "1",
            name: "Dubai Starter",
            description: "Perfect for short trips",
            dataGB: 5,
            durationDays: 7,
            priceUSD: 9.99,
            speed: "4G/LTE",
            location: "United Arab Emirates",
            locationCode: "AE"
        ))
        .environmentObject(AppCoordinator())
    }
}
