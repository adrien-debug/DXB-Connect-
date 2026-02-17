import SwiftUI
import DXBCore

struct SupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedFAQ: UUID? = nil

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
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .stroke(AppTheme.border, lineWidth: 1.5)
                            )
                    }
                    .accessibilityLabel("Fermer")

                    Spacer()

                    Text("SUPPORT")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(AppTheme.textTertiary)

                    Spacer()

                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Hero
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.gray100)
                                    .frame(width: 80, height: 80)

                                Image(systemName: "headphones")
                                    .font(.system(size: 34, weight: .semibold))
                                    .foregroundColor(AppTheme.textPrimary)
                            }

                            VStack(spacing: 6) {
                                Text("How can we help?")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)

                                Text("Find answers or contact us")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppTheme.textTertiary)
                            }
                        }
                        .padding(.top, 24)
                        .slideIn(delay: 0)

                        // Contact Options
                        HStack(spacing: 14) {
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
                        .padding(.horizontal, 24)
                        .slideIn(delay: 0.1)

                        // FAQ Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("FREQUENTLY ASKED")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(AppTheme.textTertiary)
                                .padding(.horizontal, 24)

                            VStack(spacing: 12) {
                                ForEach(Array(FAQItem.allItems.enumerated()), id: \.element.id) { index, item in
                                    FAQCardTech(
                                        item: item,
                                        isExpanded: expandedFAQ == item.id
                                    ) {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                            if expandedFAQ == item.id {
                                                expandedFAQ = nil
                                            } else {
                                                expandedFAQ = item.id
                                            }
                                        }
                                    }
                                    .slideIn(delay: 0.1 + Double(index) * 0.03)
                                }
                            }
                            .padding(.horizontal, 24)
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
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppTheme.textPrimary)
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(spacing: 4) {
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
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(AppTheme.border, lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(isPressed ? 0.01 : 0.03), radius: isPressed ? 4 : 8, x: 0, y: isPressed ? 1 : 3)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .accessibilityLabel("\(title): \(subtitle)")
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

// MARK: - FAQ Card Tech

struct FAQCardTech: View {
    let item: FAQItem
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 14) {
                    Text(item.question)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppTheme.textTertiary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(18)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Text(item.answer)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineSpacing(4)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 18)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isExpanded ? AppTheme.gray50 : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.border, lineWidth: 1.5)
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
