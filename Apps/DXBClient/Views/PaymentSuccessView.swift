import SwiftUI
import DXBCore

struct PaymentSuccessView: View {
    let plan: Plan
    let onDismiss: () -> Void

    @State private var showCheckmark = false
    @State private var showContent = false
    @State private var showConnection = false
    @State private var ringScale1 = false
    @State private var ringScale2 = false
    @State private var ringScale3 = false
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary
                .ignoresSafeArea()

            // Background world map
            WorldMapView(
                highlightedCodes: [plan.locationCode],
                showConnections: showConnection,
                accentDots: false,
                connectionCodes: [plan.locationCode],
                strokeColor: AppTheme.anthracite,
                strokeOpacity: 0.03,
                dotColor: AppTheme.accent,
                showDubaiPulse: showConnection
            )
            .ignoresSafeArea()
            .opacity(showContent ? 1 : 0)

            VStack(spacing: 0) {
                Spacer()

                // Animated success rings
                ZStack {
                    Circle()
                        .stroke(AppTheme.accent.opacity(0.05), lineWidth: 2)
                        .frame(width: 200, height: 200)
                        .scaleEffect(ringScale3 ? 1 : 0.3)
                        .opacity(ringScale3 ? 0 : 0.6)

                    Circle()
                        .stroke(AppTheme.accent.opacity(0.1), lineWidth: 2)
                        .frame(width: 160, height: 160)
                        .scaleEffect(ringScale2 ? 1 : 0.3)
                        .opacity(ringScale2 ? 0 : 0.8)

                    Circle()
                        .stroke(AppTheme.accent.opacity(0.15), lineWidth: 2)
                        .frame(width: 130, height: 130)
                        .scaleEffect(ringScale1 ? 1 : 0.3)
                        .opacity(ringScale1 ? 0 : 1)

                    Circle()
                        .fill(AppTheme.accent)
                        .frame(width: 100, height: 100)
                        .shadow(color: AppTheme.accent.opacity(0.4), radius: 30, x: 0, y: 10)

                    Image(systemName: "checkmark")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(Color(hex: "0F172A"))
                        .scaleEffect(showCheckmark ? 1 : 0)
                        .opacity(showCheckmark ? 1 : 0)
                }

                VStack(spacing: 14) {
                    Text("Payment Successful!")
                        .font(.system(size: 28, weight: .bold))
                        .tracking(-0.5)
                        .foregroundColor(AppTheme.textPrimary)

                    Text("Your eSIM is being activated.\nYou'll be connected in seconds.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                }
                .padding(.top, 36)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                // Receipt card
                VStack(spacing: 0) {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppTheme.accent.opacity(0.1))
                                .frame(width: 48, height: 48)

                            Image(systemName: "simcard.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppTheme.accent)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(plan.name)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            Text(plan.location)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(AppTheme.textTertiary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 3) {
                            Text("\(plan.dataGB) GB")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.textPrimary)

                            Text("\(plan.durationDays) days")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(AppTheme.textTertiary)
                        }
                    }
                    .padding(.bottom, 18)

                    Rectangle()
                        .fill(AppTheme.border.opacity(0.3))
                        .frame(height: 0.5)
                        .padding(.bottom, 18)

                    HStack {
                        Text("Total paid")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)

                        Spacer()

                        Text(plan.priceUSD.formattedPrice)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
                .padding(22)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(AppTheme.backgroundTertiary)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                )
                .padding(.horizontal, 24)
                .padding(.top, 36)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        HapticFeedback.light()
                        onDismiss()
                    } label: {
                        HStack(spacing: 8) {
                            Text("View my eSIMs")
                                .font(.system(size: 17, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .foregroundColor(Color(hex: "0F172A"))
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(AppTheme.accent)
                        )
                    }
                    .pulse(color: AppTheme.accent, radius: 20)
                    .scaleOnPress()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
            }

            // Confetti celebration
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            HapticFeedback.success()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.2)) {
                showCheckmark = true
            }
            withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
                ringScale1 = true
            }
            withAnimation(.easeOut(duration: 1.4).delay(0.4)) {
                ringScale2 = true
            }
            withAnimation(.easeOut(duration: 1.6).delay(0.5)) {
                ringScale3 = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
                showContent = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.9)) {
                showConnection = true
            }
            // Trigger confetti celebration
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                showConfetti = true
            }
        }
    }
}

#Preview {
    PaymentSuccessView(
        plan: Plan(
            id: "1", name: "Dubai Starter", description: "Perfect for short trips",
            dataGB: 5, durationDays: 7, priceUSD: 9.99, speed: "4G/LTE",
            location: "United Arab Emirates", locationCode: "AE"
        ),
        onDismiss: {}
    )
}
