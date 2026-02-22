import SwiftUI
import DXBCore

struct MyESIMsView: View {
    @Environment(AppState.self) private var appState

    @State private var selectedFilter: ESIMFilter = .all
    @State private var usageCache: [String: ESIMUsage] = [:]
    @State private var loadingUsage: Set<String> = []

    enum ESIMFilter: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case expired = "Expired"
    }

    private var filteredESIMs: [ESIMOrder] {
        switch selectedFilter {
        case .all:     return appState.activeESIMs
        case .active:  return appState.activeESIMs.filter { isActive($0.status) }
        case .expired: return appState.activeESIMs.filter { !isActive($0.status) }
        }
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    statsHeader.slideIn(delay: 0)
                    filterPills.slideIn(delay: 0.05)
                    esimsList.slideIn(delay: 0.1)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.base)
                .padding(.bottom, 120)
            }
            .refreshable { await appState.loadDashboard() }
        }
        .navigationTitle("My eSIMs")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    PlanListView()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(AppColors.accent)
                }
            }
        }
    }

    // MARK: - Stats

    private var statsHeader: some View {
        HStack(spacing: AppSpacing.md) {
            statBox(value: "\(appState.activeESIMs.count)", label: "Total", icon: "simcard.fill", color: AppColors.accent)
            statBox(value: "\(activeCount)", label: "Active", icon: "checkmark.circle.fill", color: AppColors.accent)
            statBox(value: "\(countriesCount)", label: "Countries", icon: "globe", color: AppColors.accent)
        }
    }

    private func statBox(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .chromeCard()
    }

    private var activeCount: Int {
        appState.activeESIMs.filter { isActive($0.status) }.count
    }

    private var countriesCount: Int {
        Set(appState.activeESIMs.map { $0.packageName }).count
    }

    // MARK: - Filters

    private var filterPills: some View {
        HStack(spacing: 8) {
            ForEach(ESIMFilter.allCases, id: \.self) { filter in
                let isSelected = selectedFilter == filter
                Button {
                    withAnimation(.spring(response: 0.3)) { selectedFilter = filter }
                } label: {
                    Text(filter.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(isSelected ? .black : AppColors.textSecondary)
                    .padding(.horizontal, AppSpacing.base)
                    .padding(.vertical, AppSpacing.sm)
                        .background(
                            Capsule()
                                .fill(isSelected ? AppColors.accent : AppColors.surface)
                                .overlay(
                                    Capsule().stroke(isSelected ? Color.clear : AppColors.border, lineWidth: 1)
                                )
                        )
                }
            }
            Spacer()
        }
    }

    // MARK: - List

    private var esimsList: some View {
        VStack(spacing: 10) {
            if appState.isDashboardLoading {
                ForEach(0..<3, id: \.self) { _ in esimLoadingCard }
            } else if filteredESIMs.isEmpty {
                emptyState
            } else {
                ForEach(filteredESIMs) { esim in
                    NavigationLink { ESIMDetailView(esim: esim) } label: {
                        esimCard(esim)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func esimCard(_ esim: ESIMOrder) -> some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(statusColor(esim.status).opacity(0.1))
                    .frame(width: 48, height: 48)

                Image(systemName: "simcard.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(statusColor(esim.status))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(esim.packageName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)

                Text(esim.totalVolume.isEmpty ? "Activation pending" : esim.totalVolume)
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                StatusBadge(text: statusLabel(esim.status), color: statusColor(esim.status))

                if let usage = usageCache[esim.iccid] {
                    Text("\(Int(usage.usagePercentage * 100))% used")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(AppColors.textTertiary)
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(AppSpacing.base)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .stroke(AppColors.border, lineWidth: 1)
                )
        )
        .task { await loadUsage(for: esim) }
    }

    private var esimLoadingCard: some View {
        HStack(spacing: AppSpacing.md) {
            Circle().fill(AppColors.surfaceSecondary).frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: AppRadius.xs).fill(AppColors.surfaceSecondary).frame(width: 130, height: 14)
                RoundedRectangle(cornerRadius: AppRadius.xs).fill(AppColors.surfaceSecondary).frame(width: 80, height: 10)
            }
            Spacer()
        }
        .padding(AppSpacing.base)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.surface)
                .overlay(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous).stroke(AppColors.border, lineWidth: 1))
        )
        .shimmer()
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            EmptyStateView(
                icon: "simcard",
                title: "No eSIMs found",
                subtitle: "Purchase your first eSIM to get started"
            )

            NavigationLink {
                PlanListView()
            } label: {
                Text("Browse Plans")
            }
            .buttonStyle(PrimaryButtonStyle(isSmall: true))
        }
        .pulseCard()
    }

    // MARK: - Helpers

    private func loadUsage(for esim: ESIMOrder) async {
        guard !esim.iccid.isEmpty, usageCache[esim.iccid] == nil, !loadingUsage.contains(esim.iccid) else { return }
        loadingUsage.insert(esim.iccid)
        do {
            guard let usage = try await appState.apiService.fetchUsage(iccid: esim.iccid) else {
                loadingUsage.remove(esim.iccid)
                return
            }
            usageCache[esim.iccid] = usage
            loadingUsage.remove(esim.iccid)
        } catch {
            loadingUsage.remove(esim.iccid)
        }
    }

    private func isActive(_ status: String) -> Bool {
        ESIMStatusHelper.isActive(status)
    }

    private func statusLabel(_ status: String) -> String {
        ESIMStatusHelper.label(status)
    }

    private func statusColor(_ status: String) -> Color {
        ESIMStatusHelper.color(status)
    }
}

#Preview {
    NavigationStack { MyESIMsView() }
        .environment(AppState())
        .preferredColorScheme(.dark)
}
