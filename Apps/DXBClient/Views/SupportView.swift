import SwiftUI

struct SupportView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: AppSpacing.lg) {
                        heroSection.slideIn(delay: 0)
                        faqSection.slideIn(delay: 0.05)
                        contactSection.slideIn(delay: 0.1)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.base)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SUPPORT")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(AppColors.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(AppColors.textTertiary)
                    }
                }
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppColors.accent.opacity(0.1))
                    .frame(width: 72, height: 72)

                Image(systemName: "headphones")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(AppColors.accent)
            }

            VStack(spacing: 6) {
                Text("How can we help?")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("We're here for you 24/7")
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xl)
    }

    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FAQ")
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundStyle(AppColors.textTertiary)

            VStack(spacing: 0) {
                faqRow(q: "How to install my eSIM?", a: "Open Settings > Cellular > Add eSIM")
                Divider().background(AppColors.border).padding(.leading, 14)
                faqRow(q: "Can I use multiple eSIMs?", a: "Yes, your phone supports dual SIM")
                Divider().background(AppColors.border).padding(.leading, 14)
                faqRow(q: "How to get a refund?", a: "Contact our support team within 24h")
            }
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(AppColors.surface)
                    .overlay(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous).stroke(AppColors.border, lineWidth: 1))
            )
        }
    }

    private func faqRow(q: String, a: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(q)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)
            Text(a)
                .font(.system(size: 13))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
    }

    private var contactSection: some View {
        VStack(spacing: 10) {
            Button {
                if let url = URL(string: "mailto:support@simpass.io") {
                    UIApplication.shared.open(url)
                }
            } label: {
                contactTile(icon: "envelope.fill", title: "Email", subtitle: "support@simpass.io", color: AppColors.info)
            }

            Button {
                if let url = URL(string: "https://simpass.io/chat") {
                    UIApplication.shared.open(url)
                }
            } label: {
                contactTile(icon: "bubble.fill", title: "Live Chat", subtitle: "Available 24/7", color: AppColors.accent)
            }
        }
    }

    private func contactTile(icon: String, title: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                    .fill(color.opacity(0.12))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .bentoCard()
    }
}

#Preview {
    SupportView()
        .preferredColorScheme(.dark)
}
