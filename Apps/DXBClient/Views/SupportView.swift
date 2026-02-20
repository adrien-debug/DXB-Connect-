import SwiftUI
import DXBCore

struct SupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedFAQ: UUID? = nil

    private typealias BankingColors = AppTheme.Banking.Colors
    private typealias BankingTypo = AppTheme.Banking.Typography
    private typealias BankingSpacing = AppTheme.Banking.Spacing

    var body: some View {
        ZStack {
            BankingColors.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(BankingTypo.button())
                            .foregroundColor(BankingColors.textOnDarkPrimary)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(BankingColors.backgroundTertiary))
                    }
                    .accessibilityLabel("Fermer")

                    Spacer()

                    Text("SUPPORT")
                        .font(BankingTypo.label())
                        .tracking(1.5)
                        .foregroundColor(BankingColors.textOnDarkMuted)

                    Spacer()

                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, BankingSpacing.xl)
                .padding(.top, BankingSpacing.sm)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: BankingSpacing.xxl) {
                        VStack(spacing: BankingSpacing.base) {
                            ZStack {
                                Circle()
                                    .fill(BankingColors.accent.opacity(0.15))
                                    .frame(width: 80, height: 80)

                                Image(systemName: "headphones")
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(BankingColors.accent)
                            }

                            Text("How can we help?")
                                .font(BankingTypo.detailAmount())
                                .foregroundColor(BankingColors.textOnDarkPrimary)

                            Text("We're here for you 24/7")
                                .font(BankingTypo.body())
                                .foregroundColor(BankingColors.textOnDarkMuted)
                        }
                        .padding(.top, BankingSpacing.lg)
                        .slideIn(delay: 0)

                        HStack(spacing: 12) {
                            ContactOptionCard(
                                icon: "envelope.fill",
                                title: "Email",
                                subtitle: "support@dxbconnect.com"
                            ) {
                                if let url = URL(string: "mailto:support@dxbconnect.com") {
                                    UIApplication.shared.open(url)
                                }
                            }

                            ContactOptionCard(
                                icon: "message.fill",
                                title: "WhatsApp",
                                subtitle: "Chat with us"
                            ) {
                                if let url = URL(string: "https://wa.me/971501234567") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .slideIn(delay: 0.1)

                        // FAQ
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Frequently asked")
                                .font(AppTheme.Typography.cardAmount())
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(.horizontal, 20)

                            VStack(spacing: 8) {
                                ForEach(Array(FAQItem.allItems.enumerated()), id: \.element.id) { index, item in
                                    FAQCardTech(
                                        item: item,
                                        isExpanded: expandedFAQ == item.id
                                    ) {
                                        HapticFeedback.light()
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                            expandedFAQ = expandedFAQ == item.id ? nil : item.id
                                        }
                                    }
                                    .slideIn(delay: 0.1 + Double(index) * 0.03)
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Contact Option Card

struct ContactOptionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button {
            HapticFeedback.light()
            action()
        } label: {
            VStack(spacing: 16) {
                Circle()
                    .fill(AppTheme.accent)
                    .frame(width: 52, height: 52)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AppTheme.anthracite)
                    )

                VStack(spacing: 5) {
                    Text(title)
                        .font(AppTheme.Typography.bodyMedium())
                        .foregroundColor(AppTheme.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(AppTheme.textTertiary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppTheme.backgroundPrimary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(AppTheme.border.opacity(0.5), lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            )
        }
        .accessibilityLabel("\(title): \(subtitle)")
        .buttonStyle(.plain)
        .scaleOnPress()
    }
}

// MARK: - FAQ Card

struct FAQCardTech: View {
    let item: FAQItem
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    Text(item.question)
                        .font(AppTheme.Typography.buttonMedium())
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(AppTheme.Typography.navTitle())
                        .foregroundColor(isExpanded ? AppTheme.accent : AppTheme.textTertiary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Text(item.answer)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineSpacing(5)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 18)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                .fill(AppTheme.backgroundPrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                        .stroke(isExpanded ? AppTheme.accent.opacity(0.25) : AppTheme.border.opacity(0.5), lineWidth: isExpanded ? 1.5 : 0.5)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - FAQ Item

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String

    static let allItems = [
        FAQItem(
            question: "How do I install my eSIM?",
            answer: "Open your Camera app and scan the QR code. Tap the notification that appears and follow the on-screen instructions. Your eSIM will be installed in Settings > Cellular."
        ),
        FAQItem(
            question: "When does my eSIM activate?",
            answer: "Your eSIM activates automatically when you connect to a supported network in Dubai. Make sure to enable the eSIM in your cellular settings."
        ),
        FAQItem(
            question: "My eSIM is not activating. What should I do?",
            answer: "1. Ensure you're in Dubai or UAE\n2. Check that the eSIM is enabled in Settings > Cellular\n3. Restart your device\n4. If issue persists, contact support"
        ),
        FAQItem(
            question: "Can I use my eSIM in multiple devices?",
            answer: "No, each eSIM is tied to a single device. If you need eSIMs for multiple devices, please purchase separate plans."
        ),
        FAQItem(
            question: "What is your refund policy?",
            answer: "We offer full refunds within 24 hours of purchase if the eSIM has not been activated. After activation, refunds are not available."
        ),
        FAQItem(
            question: "How do I check my data usage?",
            answer: "You can view your data usage in the 'My eSIMs' tab. Usage updates every few hours. You can also check in your device's Settings > Cellular."
        )
    ]
}

#Preview {
    SupportView()
}
