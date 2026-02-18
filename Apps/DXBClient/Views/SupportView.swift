import SwiftUI
import DXBCore

struct SupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedFAQ: UUID? = nil

    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(AppTheme.surfaceHeavy))
                    }
                    .accessibilityLabel("Fermer")

                    Spacer()

                    Text("SUPPORT")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(AppTheme.textTertiary)

                    Spacer()

                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.accentSoft)
                                    .frame(width: 72, height: 72)

                                Image(systemName: "headphones")
                                    .font(.system(size: 30, weight: .semibold))
                                    .foregroundColor(AppTheme.accent)
                            }

                            VStack(spacing: 6) {
                                Text("How can we help?")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)

                                Text("Find answers or contact us")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppTheme.textTertiary)
                            }
                        }
                        .padding(.top, 20)
                        .slideIn(delay: 0)

                        HStack(spacing: 12) {
                            ContactOptionCard(
                                icon: "envelope.fill",
                                title: "EMAIL",
                                subtitle: "support@dxbconnect.com"
                            ) {
                                if let url = URL(string: "mailto:support@dxbconnect.com") {
                                    UIApplication.shared.open(url)
                                }
                            }

                            ContactOptionCard(
                                icon: "message.fill",
                                title: "WHATSAPP",
                                subtitle: "Chat with us"
                            ) {
                                if let url = URL(string: "https://wa.me/971501234567") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .slideIn(delay: 0.1)

                        VStack(alignment: .leading, spacing: 14) {
                            Text("FREQUENTLY ASKED")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(AppTheme.textTertiary)
                                .padding(.horizontal, 20)

                            VStack(spacing: 10) {
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
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppTheme.accent)
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(spacing: 3) {
                    Text(title)
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundColor(AppTheme.textTertiary)

                    Text(subtitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(AppTheme.surfaceLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
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
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isExpanded ? AppTheme.accent : AppTheme.textTertiary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(16)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Text(item.answer)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isExpanded ? AppTheme.accentSoft : AppTheme.surfaceLight)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isExpanded ? AppTheme.accent.opacity(0.3) : AppTheme.border, lineWidth: 1)
                )
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
