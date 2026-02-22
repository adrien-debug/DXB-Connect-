import SwiftUI

// MARK: - Pulse Header Bar

struct TechHeaderBar: View {
    let title: String
    var subtitle: String?

    var body: some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(AppColors.accent)
                .frame(width: 3, height: 24)
                .clipShape(RoundedRectangle(cornerRadius: 2))

            VStack(alignment: .leading, spacing: 3) {
                Text(title.uppercased())
                    .font(.system(size: 13, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppColors.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            Spacer()
        }
        .padding(.horizontal, AppSpacing.lg)
    }
}

// MARK: - Pulse Stat Card

struct TechStatCard: View {
    let icon: String
    let value: String
    let label: String
    var color: Color = AppColors.accent

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                    .fill(color.opacity(0.1))
                    .frame(width: 38, height: 38)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
            }

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)

            Text(label.uppercased())
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .chromeCard()
    }
}

// MARK: - Pulse List Row

struct TechListRow: View {
    let icon: String
    let title: String
    var subtitle: String?
    var trailing: String?
    var trailingColor: Color = AppColors.textSecondary
    var showChevron: Bool = true
    var iconColor: Color = AppColors.accent

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(AppColors.textTertiary)
                }
            }

            Spacer()

            if let trailing {
                Text(trailing)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(trailingColor)
            }

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .stroke(AppColors.border, lineWidth: 1)
                )
        )
    }
}

// MARK: - Progress Bar

struct TechProgressBar: View {
    let progress: Double
    var height: CGFloat = 5
    var showGlow: Bool = true

    @State private var animatedProgress: Double = 0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(AppColors.border)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(AppColors.accent)
                    .frame(width: geo.size.width * animatedProgress)
                    .shadow(color: showGlow ? AppColors.accent.opacity(0.4) : .clear, radius: 4)
            }
        }
        .frame(height: height)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = min(progress, 1.0)
            }
        }
    }
}

// MARK: - Pulse Divider

struct TechDivider: View {
    var body: some View {
        Rectangle()
            .fill(AppColors.border)
            .frame(height: 1)
    }
}

// MARK: - Info Row

struct TechInfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = AppColors.textPrimary
    var isMono: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .semibold, design: isMono ? .monospaced : .default))
                .foregroundStyle(valueColor)
        }
    }
}

// MARK: - Preview

#Preview("Pulse Components") {
    ZStack {
        AppColors.background.ignoresSafeArea()

        ScrollView {
            VStack(spacing: 20) {
                TechHeaderBar(title: "Dashboard", subtitle: "Your eSIM control center")

                HStack(spacing: AppSpacing.md) {
                    TechStatCard(icon: "simcard.fill", value: "3", label: "Active")
                    TechStatCard(icon: "globe", value: "12", label: "Countries", color: AppColors.info)
                }
                .padding(.horizontal, AppSpacing.lg)

                VStack(spacing: 8) {
                    TechListRow(icon: "wifi", title: "Dubai 5G", subtitle: "2.3 GB remaining", trailing: "ACTIVE", trailingColor: AppColors.success)
                    TechListRow(icon: "creditcard", title: "Elite Plan", subtitle: "Renews Dec 2024", trailing: "$9.99")
                }
                .padding(.horizontal, AppSpacing.lg)

                VStack(spacing: 10) {
                    TechInfoRow(label: "Balance", value: "2,450 pts")
                    TechDivider()
                    TechInfoRow(label: "Status", value: "ELITE", valueColor: AppColors.accent)
                }
                .pulseCard()
                .padding(.horizontal, AppSpacing.lg)

                VStack(spacing: 6) {
                    Text("USAGE")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(AppColors.textSecondary)
                    TechProgressBar(progress: 0.65)
                }
                .padding(.horizontal, AppSpacing.lg)
            }
            .padding(.vertical, 20)
        }
    }
    .preferredColorScheme(.dark)
}
