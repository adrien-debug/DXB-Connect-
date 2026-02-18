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
            AppTheme.backgroundPrimary
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
                            .background(Circle().fill(AppTheme.surfaceHeavy))
                    }

                    Spacer()

                    Text("PLAN DETAILS")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(AppTheme.textTertiary)

                    Spacer()

                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Hero
                        VStack(spacing: 18) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.gray100)
                                    .frame(width: 80, height: 80)

                                Text(flagEmoji)
                                    .font(.system(size: 40))
                            }
                            .slideIn(delay: 0)

                            VStack(spacing: 6) {
                                Text(plan.location)
                                    .font(.system(size: 26, weight: .bold))
                                    .tracking(-0.5)
                                    .foregroundColor(AppTheme.textPrimary)

                                Text(plan.name)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(AppTheme.textTertiary)
                            }
                            .slideIn(delay: 0.05)
                        }
                        .padding(.top, 20)

                        // Price Card
                        VStack(spacing: 8) {
                            Text(plan.priceUSD.formattedPrice)
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .tracking(-2)
                                .foregroundColor(AppTheme.accent)

                            Text("ONE-TIME PAYMENT")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(AppTheme.textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 28)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(AppTheme.accentSoft)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(AppTheme.accent.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                        .slideIn(delay: 0.1)

                        // Features Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            FeatureTechCard(icon: "antenna.radiowaves.left.and.right", label: "DATA", value: "\(plan.dataGB) GB")
                            FeatureTechCard(icon: "calendar", label: "DURATION", value: "\(plan.durationDays) days")
                            FeatureTechCard(icon: "bolt.fill", label: "SPEED", value: plan.speed)
                            FeatureTechCard(icon: "globe", label: "COVERAGE", value: plan.location)
                        }
                        .padding(.horizontal, 20)
                        .slideIn(delay: 0.15)

                        // Included Features
                        VStack(alignment: .leading, spacing: 14) {
                            Text("INCLUDED")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(AppTheme.textTertiary)

                            VStack(spacing: 12) {
                                IncludedFeatureRow(icon: "checkmark.circle.fill", text: "Instant activation")
                                IncludedFeatureRow(icon: "checkmark.circle.fill", text: "24/7 support")
                                IncludedFeatureRow(icon: "checkmark.circle.fill", text: "No roaming fees")
                                IncludedFeatureRow(icon: "checkmark.circle.fill", text: "Keep your number")
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(AppTheme.surfaceLight)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(AppTheme.border, lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                        .slideIn(delay: 0.2)

                        Spacer(minLength: 100)
                    }
                }

                // Bottom CTA
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(AppTheme.border.opacity(0.5))
                        .frame(height: 0.5)

                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("TOTAL")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1)
                                .foregroundColor(AppTheme.textTertiary)

                            Text(plan.priceUSD.formattedPrice)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        Button {
                            HapticFeedback.medium()
                            viewModel.showPaymentSheet = true
                        } label: {
                            HStack(spacing: 10) {
                                if viewModel.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("BUY NOW")
                                        .font(.system(size: 14, weight: .bold))
                                        .tracking(1)
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppTheme.accent)
                            )
                        }
                        .disabled(viewModel.isLoading)
                        .scaleOnPress()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 34)
                    .background(
                        AppTheme.backgroundPrimary
                            .shadow(color: Color.black.opacity(0.04), radius: 8, y: -2)
                    )
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $viewModel.showSuccess) {
            PaymentSuccessView(plan: plan) {
                viewModel.showSuccess = false
                coordinator.selectedTab = 2
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
                    .foregroundColor(AppTheme.textTertiary)

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
                .fill(AppTheme.surfaceLight)
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
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.success)

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)

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
                .foregroundColor(AppTheme.textTertiary)

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
