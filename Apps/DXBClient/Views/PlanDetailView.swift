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
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom Nav Bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .stroke(AppTheme.border, lineWidth: 1.5)
                            )
                    }

                    Spacer()

                    Text("PLAN DETAILS")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(AppTheme.textTertiary)

                    Spacer()

                    // Placeholder for symmetry
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Hero Section
                        VStack(spacing: 20) {
                            // Flag
                            ZStack {
                                Circle()
                                    .fill(AppTheme.gray100)
                                    .frame(width: 88, height: 88)

                                Text(flagEmoji)
                                    .font(.system(size: 44))
                            }
                            .slideIn(delay: 0)

                            VStack(spacing: 8) {
                                Text(plan.location)
                                    .font(.system(size: 28, weight: .bold))
                                    .tracking(-0.5)
                                    .foregroundColor(AppTheme.textPrimary)

                                Text(plan.name)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(AppTheme.textTertiary)
                            }
                            .slideIn(delay: 0.05)
                        }
                        .padding(.top, 24)

                        // Price Card
                        VStack(spacing: 8) {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(plan.priceUSD.formattedPrice)
                                    .font(.system(size: 56, weight: .bold))
                                    .tracking(-2)
                                    .foregroundColor(AppTheme.textPrimary)
                            }

                            Text("ONE-TIME PAYMENT")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(AppTheme.textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(AppTheme.gray50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(AppTheme.border, lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 24)
                        .slideIn(delay: 0.1)

                        // Features Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                            FeatureTechCard(icon: "antenna.radiowaves.left.and.right", label: "DATA", value: "\(plan.dataGB) GB")
                            FeatureTechCard(icon: "calendar", label: "DURATION", value: "\(plan.durationDays) days")
                            FeatureTechCard(icon: "bolt.fill", label: "SPEED", value: plan.speed)
                            FeatureTechCard(icon: "globe", label: "COVERAGE", value: plan.location)
                        }
                        .padding(.horizontal, 24)
                        .slideIn(delay: 0.15)

                        // Included Features
                        VStack(alignment: .leading, spacing: 16) {
                            Text("INCLUDED")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(AppTheme.textTertiary)

                            VStack(spacing: 14) {
                                IncludedFeatureRow(icon: "checkmark.circle.fill", text: "Instant activation")
                                IncludedFeatureRow(icon: "checkmark.circle.fill", text: "24/7 support")
                                IncludedFeatureRow(icon: "checkmark.circle.fill", text: "No roaming fees")
                                IncludedFeatureRow(icon: "checkmark.circle.fill", text: "Keep your number")
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(AppTheme.border, lineWidth: 1.5)
                                )
                        )
                        .padding(.horizontal, 24)
                        .slideIn(delay: 0.2)

                        Spacer(minLength: 120)
                    }
                }

                // Fixed Bottom CTA
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(AppTheme.border)
                        .frame(height: 1)

                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("TOTAL")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1)
                                .foregroundColor(AppTheme.textTertiary)

                            Text(plan.priceUSD.formattedPrice)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        Button {
                            viewModel.showPaymentSheet = true
                        } label: {
                            HStack(spacing: 10) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
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
                                    .fill(AppTheme.textPrimary)
                            )
                        }
                        .disabled(viewModel.isLoading)
                        .scaleOnPress()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 34)
                    .background(Color.white)
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $viewModel.showSuccess) {
            PaymentSuccessView(plan: plan) {
                viewModel.showSuccess = false
                coordinator.selectedTab = 2 // Go to My eSIMs
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
                    // Reload eSIMs
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

// MARK: - Feature Tech Card

struct FeatureTechCard: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.textPrimary)
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundColor(AppTheme.textTertiary)

                Text(value)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.border, lineWidth: 1.5)
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
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)

            Spacer()
        }
    }
}

// MARK: - Legacy Feature Row (compatibility)

struct FeatureRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 32)
                .foregroundColor(AppTheme.textPrimary)

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
