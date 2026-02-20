import SwiftUI

// MARK: - Design Showcase (Standalone — no auth/backend needed)

struct DesignShowcaseView: View {
    @State private var selectedTab = 0
    @State private var showAuth = false
    @State private var showSupport = false

    var body: some View {
        ZStack(alignment: .bottom) {
            if showAuth {
                MockAuthView(showAuth: $showAuth)
            } else {
                Group {
                    switch selectedTab {
                    case 0: NavigationStack { MockDashboardView() }
                    case 1: NavigationStack { MockExploreView() }
                    case 2: NavigationStack { MockMyESIMsView() }
                    case 3: MockProfileView()
                    default: NavigationStack { MockDashboardView() }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(spacing: 0) {
                    Spacer()
                    ShowcaseTabBar(selectedTab: $selectedTab)
                }
                .ignoresSafeArea(.all, edges: .bottom)
            }
        }
        .ignoresSafeArea(.keyboard)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showSupport) {
            MockSupportView()
        }
    }
}

// MARK: - Mock Dashboard

struct MockDashboardView: View {
    @State private var ringAppear = false

    var body: some View {
        ZStack {
            Color(hex: "09090B").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    mockHeroHeader
                    mockContentSection
                }
            }
        }
    }

    private var mockHeroHeader: some View {
        VStack(spacing: 0) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Circle()
                    .fill(Color(hex: "CDFF00"))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text("A")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "0F172A"))
                    )

                VStack(alignment: .leading, spacing: 0) {
                    Text("Good evening")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(Color(hex: "71717A"))

                    Text("Adrien")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }

                Spacer()

                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(hex: "27272A"))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "ellipsis")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        )

                    ZStack(alignment: .topTrailing) {
                        Circle()
                            .fill(Color(hex: "27272A"))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: "bell")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                            )

                        Circle()
                            .fill(Color(hex: "CDFF00"))
                            .frame(width: 8, height: 8)
                            .offset(x: 0, y: 2)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 16)

            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("Total Balance")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(hex: "0F172A").opacity(0.6))

                    Text("$8,312.64")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .tracking(-2)
                        .foregroundColor(Color(hex: "0F172A"))
                }
                .padding(.top, 8)

                HStack(spacing: 8) {
                    Button {} label: {
                        HStack(spacing: 6) {
                            Text("Buy eSIM")
                                .font(.system(size: 14, weight: .bold))
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "0F172A")))
                    }

                    Button {} label: {
                        HStack(spacing: 6) {
                            Text("Scan QR")
                                .font(.system(size: 14, weight: .bold))
                            Image(systemName: "qrcode")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "0F172A")))
                    }

                    Button {} label: {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "0F172A"))
                            .frame(width: 48, height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white.opacity(0.5))
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity)
            .background(Color(hex: "CDFF00"))
        }
    }

    private var mockContentSection: some View {
        VStack(spacing: 0) {
            mockCardsSection
            mockDataUsageRow
            mockRecentActivity
        }
        .padding(.top, 24)
        .padding(.bottom, 100)
        .background(
            Color.white
                .clipShape(RoundedCorner(radius: 28, corners: [.topLeft, .topRight]))
        )
        .offset(y: -20)
    }

    private var mockCardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cards")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color(hex: "09090B"))
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    MockESIMCard(name: "Dubai 5GB", data: "$6,461.67", iccid: "*4315", type: "Debit", isDark: true)
                    MockESIMCard(name: "Europe 10GB", data: "$1,850.97", iccid: "*5161", type: "Virtual", isDark: false)

                    Button {} label: {
                        VStack {
                            Spacer()
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .light))
                                .foregroundColor(Color(hex: "A1A1AA"))
                            Spacer()
                        }
                        .frame(width: 80, height: 100)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(hex: "F4F4F5"))
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 4)
    }

    private var mockDataUsageRow: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color(hex: "E4E4E7"), lineWidth: 4)
                    .frame(width: 44, height: 44)

                Circle()
                    .trim(from: 0, to: 0.69)
                    .stroke(Color(hex: "CDFF00"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Monthly budget")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(hex: "09090B"))

                Text("$110.87 a day")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(hex: "71717A"))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("$1,219.57")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "09090B"))

                Text("left of $4,000.00")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(hex: "71717A"))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private var mockRecentActivity: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent transactions")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color(hex: "09090B"))
                .padding(.horizontal, 20)

            VStack(spacing: 0) {
                MockTransactionRow(icon: "simcard.fill", name: "Dubai eSIM", subtitle: "Data Plan", amount: "-$12.99", time: "6:41 PM", isExpense: true, iconBg: Color(hex: "CDFF00"))
                MockTransactionRow(icon: "person.fill", name: "Bob Green", subtitle: "Transaction", amount: "+$750.00", time: "4:17 PM", isExpense: false, iconBg: Color(hex: "E4E4E7"))
                MockTransactionRow(icon: "airplane", name: "Travel Pass", subtitle: "LA—Dubai", amount: "-$47.49", time: "2:32 PM", isExpense: true, iconBg: Color(hex: "E4E4E7"))
                MockTransactionRow(icon: "globe", name: "Europe Pack", subtitle: "10GB Data", amount: "-$24.99", time: "11:45 AM", isExpense: true, iconBg: Color(hex: "CDFF00"))
                MockTransactionRow(icon: "arrow.down.circle.fill", name: "Top Up", subtitle: "Balance", amount: "+$500.00", time: "8:20 AM", isExpense: false, iconBg: Color(hex: "E4E4E7"))
            }
        }
    }
}

// MARK: - Mock eSIM Card

struct MockESIMCard: View {
    let name: String
    let data: String
    let iccid: String
    let type: String
    let isDark: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "simcard.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isDark ? Color(hex: "CDFF00") : Color(hex: "09090B"))
                Spacer()
            }

            Spacer()

            Text(data)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(isDark ? .white : Color(hex: "09090B"))

            HStack(spacing: 6) {
                Text(type)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(isDark ? Color(hex: "CDFF00") : .white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(isDark ? Color(hex: "CDFF00").opacity(0.2) : Color(hex: "09090B"))
                    )

                Text(iccid)
                    .font(.system(size: 11, weight: .regular))
            }
            .foregroundColor(isDark ? .white.opacity(0.5) : Color(hex: "71717A"))
        }
        .padding(12)
        .frame(width: 160, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isDark ? Color(hex: "18181B") : Color(hex: "E4E4E7"))
        )
    }
}

// MARK: - Mock Transaction Row

struct MockTransactionRow: View {
    let icon: String
    let name: String
    let subtitle: String
    let amount: String
    let time: String
    let isExpense: Bool
    let iconBg: Color

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(iconBg.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(iconBg == Color(hex: "CDFF00") ? Color(hex: "09090B") : Color(hex: "52525B"))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "09090B"))
                    .lineLimit(1)

                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(hex: "71717A"))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(amount)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isExpense ? Color(hex: "09090B") : Color(hex: "16A34A"))

                Text(time)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(hex: "71717A"))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

// MARK: - Mock Explore View

struct MockExploreView: View {
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    let filters = ["All", "1GB", "2GB", "5GB", "10GB"]

    var body: some View {
        ZStack {
            Color(hex: "09090B").ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("ESIM PLANS")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.2)
                        .foregroundColor(Color(hex: "71717A"))

                    Text("Explore")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)

                    Text("124 plans available")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(Color(hex: "71717A"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 52)
                .padding(.bottom, 12)

                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "71717A"))

                        TextField("Search plans...", text: $searchText)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: "18181B"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: "27272A"), lineWidth: 1)
                            )
                    )

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(filters, id: \.self) { filter in
                                MockChip(title: filter, isSelected: selectedFilter == filter) {
                                    selectedFilter = filter
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        NavigationLink { MockPlanDetailView() } label: {
                            MockPlanRow(flag: "🇦🇪", location: "United Arab Emirates", data: "5GB", days: "7d", speed: "5G", price: "$12.99")
                        }.buttonStyle(.plain)
                        NavigationLink { MockPlanDetailView() } label: {
                            MockPlanRow(flag: "🇹🇷", location: "Turkey", data: "3GB", days: "15d", speed: "4G", price: "$8.49")
                        }.buttonStyle(.plain)
                        NavigationLink { MockPlanDetailView() } label: {
                            MockPlanRow(flag: "🇪🇺", location: "Europe", data: "10GB", days: "30d", speed: "5G", price: "$24.99")
                        }.buttonStyle(.plain)
                        NavigationLink { MockPlanDetailView() } label: {
                            MockPlanRow(flag: "🇺🇸", location: "United States", data: "5GB", days: "7d", speed: "5G", price: "$14.99")
                        }.buttonStyle(.plain)
                        NavigationLink { MockPlanDetailView() } label: {
                            MockPlanRow(flag: "🇸🇦", location: "Saudi Arabia", data: "2GB", days: "7d", speed: "4G", price: "$6.99")
                        }.buttonStyle(.plain)
                        NavigationLink { MockPlanDetailView() } label: {
                            MockPlanRow(flag: "🇬🇧", location: "United Kingdom", data: "5GB", days: "14d", speed: "5G", price: "$15.99")
                        }.buttonStyle(.plain)
                        NavigationLink { MockPlanDetailView() } label: {
                            MockPlanRow(flag: "🇯🇵", location: "Japan", data: "3GB", days: "7d", speed: "5G", price: "$11.99")
                        }.buttonStyle(.plain)
                        NavigationLink { MockPlanDetailView() } label: {
                            MockPlanRow(flag: "🇶🇦", location: "Qatar", data: "1GB", days: "7d", speed: "4G", price: "$4.99")
                        }.buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

struct MockChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(isSelected ? .black : Color(hex: "71717A"))
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color(hex: "CDFF00") : Color(hex: "18181B"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isSelected ? Color.clear : Color(hex: "27272A"), lineWidth: 1)
                        )
                )
        }
    }
}

struct MockPlanRow: View {
    let flag: String
    let location: String
    let data: String
    let days: String
    let speed: String
    let price: String

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "27272A"))
                .frame(width: 48, height: 48)
                .overlay(
                    Text(flag)
                        .font(.system(size: 22))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(location)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Text(data)
                        .font(.system(size: 11, weight: .regular))
                    Text("·")
                    Text(days)
                        .font(.system(size: 11, weight: .regular))
                    Text("·")
                    Text(speed)
                        .font(.system(size: 11, weight: .regular))
                }
                .foregroundColor(Color(hex: "71717A"))
            }

            Spacer()

            Text(price)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: "71717A"))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "18181B"))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(hex: "27272A"), lineWidth: 1)
                )
        )
    }
}

// MARK: - Mock My eSIMs View

struct MockMyESIMsView: View {
    @State private var selectedSegment = 0

    var body: some View {
        ZStack {
            Color(hex: "09090B").ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("MY ESIMS")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.2)
                        .foregroundColor(Color(hex: "71717A"))

                    Text("Your eSIMs")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 52)
                .padding(.bottom, 16)

                HStack(spacing: 0) {
                    ForEach(["Active", "All"], id: \.self) { tab in
                        let idx = tab == "Active" ? 0 : 1
                        Button {
                            withAnimation(.spring(response: 0.3)) { selectedSegment = idx }
                        } label: {
                            Text(tab)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedSegment == idx ? .black : Color(hex: "71717A"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedSegment == idx ? Color(hex: "CDFF00") : Color.clear)
                                )
                        }
                    }
                }
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "18181B"))
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        NavigationLink { MockESIMDetailView() } label: {
                            MockESIMRow(flag: "🇦🇪", name: "Dubai 5GB - 7 Days", data: "5 GB", status: "ACTIVE", statusColor: Color(hex: "16A34A"))
                        }.buttonStyle(.plain)
                        NavigationLink { MockESIMDetailView() } label: {
                            MockESIMRow(flag: "🇪🇺", name: "Europe 10GB - 30 Days", data: "10 GB", status: "IN USE", statusColor: Color(hex: "D97706"))
                        }.buttonStyle(.plain)
                        NavigationLink { MockESIMDetailView() } label: {
                            MockESIMRow(flag: "🇹🇷", name: "Turkey 3GB - 15 Days", data: "3 GB", status: "ACTIVE", statusColor: Color(hex: "16A34A"))
                        }.buttonStyle(.plain)
                        NavigationLink { MockESIMDetailView() } label: {
                            MockESIMRow(flag: "🇸🇦", name: "Saudi Arabia 2GB", data: "2 GB", status: "EXPIRED", statusColor: Color(hex: "71717A"))
                        }.buttonStyle(.plain)
                        NavigationLink { MockESIMDetailView() } label: {
                            MockESIMRow(flag: "🇺🇸", name: "USA 5GB - 7 Days", data: "5 GB", status: "EXPIRED", statusColor: Color(hex: "71717A"))
                        }.buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

struct MockESIMRow: View {
    let flag: String
    let name: String
    let data: String
    let status: String
    let statusColor: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "27272A"))
                    .frame(width: 48, height: 48)

                Text(flag)
                    .font(.system(size: 22))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 10, weight: .bold))
                        Text(data)
                            .font(.system(size: 11, weight: .regular))
                    }
                }
                .foregroundColor(Color(hex: "71717A"))
            }

            Spacer()

            HStack(spacing: 5) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 5, height: 5)

                Text(status)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.4)
                    .foregroundColor(statusColor)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(statusColor.opacity(0.1))
            )

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "52525B"))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "18181B"))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(hex: "27272A"), lineWidth: 1)
                )
        )
    }
}

// MARK: - Mock Profile View

struct MockProfileView: View {
    @State private var notificationsOn = true

    var body: some View {
        ZStack {
            Color(hex: "09090B").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    mockProfileHeader
                    mockStatsCard
                    mockAccountSection
                    mockPreferencesSection
                    mockSupportSection
                    mockSignOutButton
                    mockAppInfo
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
        }
    }

    private var mockProfileHeader: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(Color(hex: "CDFF00"))
                .frame(width: 64, height: 64)
                .overlay(
                    Text("A")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color(hex: "0F172A"))
                )

            VStack(spacing: 4) {
                Text("Adrien B.")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Text("adrien@dxbconnect.com")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color(hex: "71717A"))

                Text("PRO")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.8)
                    .foregroundColor(Color(hex: "CDFF00"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(Color(hex: "CDFF00").opacity(0.1))
                    )
            }
        }
        .padding(.top, 52)
    }

    private var mockStatsCard: some View {
        HStack(spacing: 0) {
            MockProfileStat(value: "5", label: "ESIMS", icon: "simcard.fill")
            Rectangle().fill(Color(hex: "27272A")).frame(width: 1, height: 32)
            MockProfileStat(value: "4", label: "COUNTRIES", icon: "globe")
            Rectangle().fill(Color(hex: "27272A")).frame(width: 1, height: 32)
            MockProfileStat(value: "$36", label: "SAVED", icon: "dollarsign.circle.fill")
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: "18181B"))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "27272A"), lineWidth: 1)
                )
        )
    }

    private var mockAccountSection: some View {
        MockSectionCard(title: "ACCOUNT") {
            VStack(spacing: 0) {
                MockSettingsRow(icon: "person.fill", title: "Edit Profile")
                MockDivider()
                MockSettingsRow(icon: "creditcard.fill", title: "Payment Methods")
                MockDivider()
                MockSettingsRow(icon: "clock.arrow.circlepath", title: "Order History")
                MockDivider()
                MockSettingsRow(icon: "gift.fill", title: "Refer a Friend", badge: "$10")
            }
        }
    }

    private var mockPreferencesSection: some View {
        MockSectionCard(title: "PREFERENCES") {
            VStack(spacing: 0) {
                MockToggleRow(icon: "bell.fill", title: "Notifications", isOn: $notificationsOn)
                MockDivider()
                MockSettingsRow(icon: "globe", title: "Language", value: "English")
                MockDivider()
                MockSettingsRow(icon: "moon.fill", title: "Appearance", value: "Dark")
            }
        }
    }

    private var mockSupportSection: some View {
        MockSectionCard(title: "SUPPORT") {
            VStack(spacing: 0) {
                MockSettingsRow(icon: "questionmark.circle.fill", title: "Help Center")
                MockDivider()
                MockSettingsRow(icon: "envelope.fill", title: "Contact Us")
                MockDivider()
                MockSettingsRow(icon: "doc.text.fill", title: "Terms & Privacy")
            }
        }
    }

    private var mockSignOutButton: some View {
        Button {} label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 14, weight: .medium))
                Text("Sign Out")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(Color(hex: "DC2626"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "18181B"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: "27272A"), lineWidth: 1)
                    )
            )
        }
    }

    private var mockAppInfo: some View {
        VStack(spacing: 3) {
            Text("DXB CONNECT")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.5)
                .foregroundColor(Color(hex: "52525B"))

            Text("Version 1.0.0")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color(hex: "3F3F46"))
        }
        .padding(.top, 8)
    }
}

// MARK: - Mock Profile Components

struct MockProfileStat: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color(hex: "52525B"))

            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            Text(label)
                .font(.system(size: 10, weight: .bold))
                .tracking(0.5)
                .foregroundColor(Color(hex: "52525B"))
        }
        .frame(maxWidth: .infinity)
    }
}

struct MockSectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .tracking(1.5)
                .foregroundColor(Color(hex: "52525B"))

            content()
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(hex: "18181B"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(hex: "27272A"), lineWidth: 1)
                        )
                )
        }
    }
}

struct MockSettingsRow: View {
    let icon: String
    let title: String
    var value: String? = nil
    var badge: String? = nil

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(hex: "52525B"))
                .frame(width: 24)

            Text(title)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.white)

            Spacer()

            if let badge = badge {
                Text(badge)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(hex: "CDFF00"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color(hex: "CDFF00").opacity(0.12)))
            }

            if let value = value {
                Text(value)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(hex: "52525B"))
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: "52525B"))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 13)
    }
}

struct MockToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(hex: "52525B"))
                .frame(width: 24)

            Text(title)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.white)

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(Color(hex: "CDFF00"))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

struct MockDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color(hex: "27272A"))
            .frame(height: 1)
            .padding(.leading, 52)
    }
}

// MARK: - Showcase Tab Bar

struct ShowcaseTabBar: View {
    @Binding var selectedTab: Int

    private let tabs: [(icon: String, activeIcon: String, label: String)] = [
        ("house", "house.fill", "Home"),
        ("safari", "safari.fill", "Explore"),
        ("simcard", "simcard.fill", "eSIMs"),
        ("person", "person.fill", "Profile")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button {
                    guard selectedTab != index else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: selectedTab == index ? tabs[index].activeIcon : tabs[index].icon)
                            .font(.system(size: 18, weight: selectedTab == index ? .semibold : .regular))
                            .foregroundColor(selectedTab == index ? Color(hex: "CDFF00") : Color.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color(hex: "0F172A"))
                .shadow(color: Color.black.opacity(0.08), radius: 8, y: 3)
        )
        .padding(.horizontal, 32)
        .padding(.bottom, 20)
    }
}

// MARK: - Mock Auth View

struct MockAuthView: View {
    @Binding var showAuth: Bool

    var body: some View {
        ZStack {
            Color(hex: "09090B").ignoresSafeArea()

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "CDFF00").opacity(0.08), Color.clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 300
                    )
                )
                .frame(width: 600, height: 600)
                .offset(y: -100)

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 28) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "CDFF00").opacity(0.12))
                            .frame(width: 140, height: 140)

                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color(hex: "CDFF00"))
                            .frame(width: 100, height: 100)
                            .shadow(color: Color(hex: "CDFF00").opacity(0.3), radius: 24, y: 12)

                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundColor(Color(hex: "0F172A"))
                    }

                    VStack(spacing: 8) {
                        Text("DXB CONNECT")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .tracking(2)
                            .foregroundColor(.white)

                        Text("Connected the moment you land")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color(hex: "A1A1AA"))
                    }
                }

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        showAuth = false
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("LOGIN")
                                .font(.system(size: 14, weight: .bold))
                                .tracking(1)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .foregroundColor(Color(hex: "0F172A"))
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(hex: "CDFF00"))
                        )
                    }

                    Button {
                        showAuth = false
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 17, weight: .semibold))
                            Text("CREATE ACCOUNT")
                                .font(.system(size: 14, weight: .bold))
                                .tracking(1)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(hex: "18181B"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color(hex: "27272A"), lineWidth: 1.5)
                                )
                        )
                    }
                }
                .padding(.horizontal, 24)

                VStack(spacing: 8) {
                    Text("By continuing, you agree to our")
                        .foregroundColor(Color(hex: "3F3F46"))

                    HStack(spacing: 4) {
                        Text("Terms of Service")
                            .foregroundColor(Color(hex: "CDFF00"))
                        Text("&")
                            .foregroundColor(Color(hex: "3F3F46"))
                        Text("Privacy Policy")
                            .foregroundColor(Color(hex: "CDFF00"))
                    }
                }
                .font(.system(size: 11, weight: .regular))
                .padding(.top, 28)
                .padding(.bottom, 48)
            }
        }
    }
}

// MARK: - Mock Plan Detail View

struct MockPlanDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showCheckout = false
    @State private var showSuccess = false

    var body: some View {
        ZStack {
            Color(hex: "09090B").ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color(hex: "18181B")))
                    }
                    Spacer()
                    Text("PLAN DETAILS")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(Color(hex: "52525B"))
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(spacing: 18) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "18181B"))
                                    .frame(width: 80, height: 80)
                                Text("🇦🇪")
                                    .font(.system(size: 40))
                            }
                            VStack(spacing: 6) {
                                Text("United Arab Emirates")
                                    .font(.system(size: 26, weight: .bold))
                                    .tracking(-0.5)
                                    .foregroundColor(.white)
                                Text("Dubai Starter - 5GB")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color(hex: "52525B"))
                            }
                        }
                        .padding(.top, 20)

                        VStack(spacing: 8) {
                            Text("$12.99")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .tracking(-2)
                                .foregroundColor(Color(hex: "0F172A"))
                            Text("ONE-TIME PAYMENT")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(Color(hex: "0F172A").opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 28)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color(hex: "CDFF00")))
                        .padding(.horizontal, 20)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            MockFeatureCard(icon: "antenna.radiowaves.left.and.right", label: "DATA", value: "5 GB")
                            MockFeatureCard(icon: "calendar", label: "DURATION", value: "7 days")
                            MockFeatureCard(icon: "bolt.fill", label: "SPEED", value: "5G")
                            MockFeatureCard(icon: "globe", label: "COVERAGE", value: "UAE")
                        }
                        .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 14) {
                            Text("INCLUDED")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(Color(hex: "52525B"))

                            VStack(spacing: 12) {
                                MockIncludedRow(text: "Instant activation")
                                MockIncludedRow(text: "24/7 support")
                                MockIncludedRow(text: "No roaming fees")
                                MockIncludedRow(text: "Keep your number")
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: "18181B"))
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "27272A"), lineWidth: 1))
                        )
                        .padding(.horizontal, 20)

                        Spacer(minLength: 100)
                    }
                }

                VStack(spacing: 0) {
                    Rectangle().fill(Color(hex: "18181B")).frame(height: 0.5)
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("TOTAL")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1)
                                .foregroundColor(Color(hex: "52525B"))
                            Text("$12.99")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        Button { showCheckout = true } label: {
                            HStack(spacing: 10) {
                                Text("BUY NOW")
                                    .font(.system(size: 14, weight: .bold))
                                    .tracking(1)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .foregroundColor(Color(hex: "0F172A"))
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "CDFF00")))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 34)
                    .background(Color(hex: "09090B").shadow(color: .black.opacity(0.2), radius: 8, y: -2))
                }
            }
        }
        .sheet(isPresented: $showCheckout) {
            MockCheckoutView(showSuccess: $showSuccess)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
        .fullScreenCover(isPresented: $showSuccess) {
            MockPaymentSuccessView(showSuccess: $showSuccess)
        }
    }
}

struct MockFeatureCard: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "CDFF00").opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "CDFF00"))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundColor(Color(hex: "52525B"))
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "18181B"))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "27272A"), lineWidth: 1))
        )
    }
}

struct MockIncludedRow: View {
    let text: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "CDFF00"))
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(hex: "71717A"))
            Spacer()
        }
    }
}

// MARK: - Mock Checkout View

struct MockCheckoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var showSuccess: Bool

    var body: some View {
        ZStack {
            Color(hex: "09090B").ignoresSafeArea()

            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color(hex: "27272A"))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CHECKOUT")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.5)
                            .foregroundColor(Color(hex: "52525B"))
                        Text("United Arab Emirates")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color(hex: "18181B")))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(spacing: 14) {
                            HStack {
                                Text("ORDER SUMMARY")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1.5)
                                    .foregroundColor(Color(hex: "52525B"))
                                Spacer()
                            }

                            VStack(spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Dubai Starter - 5GB")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                        Text("5 GB • 7 days")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color(hex: "52525B"))
                                    }
                                    Spacer()
                                    Text("$12.99")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }

                                Rectangle().fill(Color(hex: "27272A")).frame(height: 1)

                                HStack {
                                    Text("Total")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("$12.99")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(hex: "CDFF00"))
                                }
                            }
                            .padding(18)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color(hex: "18181B"))
                                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "27272A"), lineWidth: 1))
                            )
                        }

                        VStack(spacing: 14) {
                            HStack {
                                Text("PAYMENT METHOD")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1.5)
                                    .foregroundColor(Color(hex: "52525B"))
                                Spacer()
                            }

                            VStack(spacing: 12) {
                                Button {
                                    dismiss()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { showSuccess = true }
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "apple.logo")
                                            .font(.system(size: 20))
                                        Text("Pay")
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .foregroundColor(.white)
                                    .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "0F172A")))
                                }

                                HStack(spacing: 16) {
                                    Rectangle().fill(Color(hex: "27272A")).frame(height: 1)
                                    Text("or")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Color(hex: "52525B"))
                                    Rectangle().fill(Color(hex: "27272A")).frame(height: 1)
                                }

                                Button {
                                    dismiss()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { showSuccess = true }
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "creditcard.fill")
                                            .font(.system(size: 18))
                                        Text("Pay with Card")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .foregroundColor(.white)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color(hex: "18181B"))
                                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "27272A"), lineWidth: 1.5))
                                    )
                                }
                            }
                        }

                        HStack(spacing: 8) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "CDFF00"))
                            Text("Secured by Stripe. Your payment details are encrypted.")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "52525B"))
                            Spacer()
                        }
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "18181B")))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

// MARK: - Mock Payment Success View

struct MockPaymentSuccessView: View {
    @Binding var showSuccess: Bool
    @State private var showCheckmark = false
    @State private var showContent = false
    @State private var pulseAnimation = false

    var body: some View {
        ZStack {
            Color(hex: "09090B").ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color(hex: "CDFF00").opacity(0.1), lineWidth: 2)
                        .frame(width: 160, height: 160)
                        .scaleEffect(pulseAnimation ? 1.3 : 1)
                        .opacity(pulseAnimation ? 0 : 1)

                    Circle()
                        .stroke(Color(hex: "CDFF00").opacity(0.2), lineWidth: 2)
                        .frame(width: 140, height: 140)
                        .scaleEffect(pulseAnimation ? 1.2 : 1)
                        .opacity(pulseAnimation ? 0 : 1)

                    Circle()
                        .fill(Color(hex: "CDFF00"))
                        .frame(width: 120, height: 120)
                        .shadow(color: Color(hex: "CDFF00").opacity(0.3), radius: 24, y: 8)

                    Image(systemName: "checkmark")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color(hex: "0F172A"))
                        .scaleEffect(showCheckmark ? 1 : 0)
                        .opacity(showCheckmark ? 1 : 0)
                }

                VStack(spacing: 14) {
                    Text("Payment Successful!")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                    Text("Your eSIM is being activated")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "52525B"))
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 16)

                VStack(spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Dubai Starter - 5GB")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            Text("United Arab Emirates")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "52525B"))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("5 GB")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            Text("7 days")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "52525B"))
                        }
                    }
                    Rectangle().fill(Color(hex: "27272A")).frame(height: 1)
                    HStack {
                        Text("Total Paid")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color(hex: "71717A"))
                        Spacer()
                        Text("$12.99")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "CDFF00"))
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "18181B"))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "27272A"), lineWidth: 1))
                )
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 16)

                Spacer()

                Button { showSuccess = false } label: {
                    HStack(spacing: 10) {
                        Text("VIEW MY eSIMs")
                            .font(.system(size: 14, weight: .bold))
                            .tracking(1)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundColor(Color(hex: "0F172A"))
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "CDFF00")))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) { showCheckmark = true }
            withAnimation(.easeOut(duration: 0.5).delay(0.4)) { showContent = true }
            withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) { pulseAnimation = true }
        }
    }
}

// MARK: - Mock eSIM Detail View

struct MockESIMDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showCopied = false

    var body: some View {
        ZStack {
            Color(hex: "09090B").ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color(hex: "18181B")))
                    }
                    Spacer()
                    Text("ESIM DETAILS")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(Color(hex: "52525B"))
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Status + QR
                        VStack(spacing: 18) {
                            HStack(spacing: 6) {
                                Circle().fill(Color(hex: "16A34A")).frame(width: 8, height: 8)
                                Text("ACTIVE")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1)
                                    .foregroundColor(Color(hex: "16A34A"))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color(hex: "16A34A").opacity(0.1)))

                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(hex: "18181B"))
                                    .frame(width: 200, height: 200)
                                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "27272A"), lineWidth: 1))

                                VStack(spacing: 12) {
                                    Image(systemName: "qrcode")
                                        .font(.system(size: 80, weight: .ultraLight))
                                        .foregroundColor(.white.opacity(0.8))
                                    Text("QR Code")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color(hex: "71717A"))
                                }
                            }

                            Text("Scan to install eSIM")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: "71717A"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(RoundedRectangle(cornerRadius: 24).fill(Color(hex: "18181B")))
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                        // Package Info
                        VStack(alignment: .leading, spacing: 14) {
                            Text("PACKAGE")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(Color(hex: "71717A"))

                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(hex: "CDFF00").opacity(0.15))
                                        .frame(width: 48, height: 48)
                                    Image(systemName: "simcard.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color(hex: "CDFF00"))
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Dubai 5GB - 7 Days")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("5 GB")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: "71717A"))
                                }
                                Spacer()
                            }

                            HStack(spacing: 10) {
                                MockInfoMiniCard(label: "EXPIRES", value: "2026-03-15")
                                MockInfoMiniCard(label: "ORDER", value: "#A8F92C")
                            }
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: "18181B"))
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "27272A"), lineWidth: 1))
                        )
                        .padding(.horizontal, 20)

                        // Technical Info
                        VStack(alignment: .leading, spacing: 14) {
                            Text("TECHNICAL INFO")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(Color(hex: "71717A"))

                            VStack(spacing: 0) {
                                MockTechInfoRow(label: "ICCID", value: "8901234567890123456") { showCopied = true }
                                Rectangle().fill(Color(hex: "3F3F46")).frame(height: 0.5).padding(.leading, 16)
                                MockTechInfoRow(label: "LPA Code", value: "LPA:1$example.com$123") { showCopied = true }
                                Rectangle().fill(Color(hex: "3F3F46")).frame(height: 0.5).padding(.leading, 16)
                                MockTechInfoRow(label: "Order No", value: "ORD-2026-A8F92C") { showCopied = true }
                            }
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "27272A")))
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: "18181B"))
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "27272A"), lineWidth: 1))
                        )
                        .padding(.horizontal, 20)

                        // Installation
                        VStack(alignment: .leading, spacing: 14) {
                            Text("INSTALLATION")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(Color(hex: "71717A"))

                            VStack(spacing: 16) {
                                MockInstallStep(number: 1, text: "Go to Settings → Cellular")
                                MockInstallStep(number: 2, text: "Tap 'Add eSIM' or 'Add Cellular Plan'")
                                MockInstallStep(number: 3, text: "Scan the QR code above")
                                MockInstallStep(number: 4, text: "Follow the on-screen instructions")
                            }
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: "18181B"))
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "27272A"), lineWidth: 1))
                        )
                        .padding(.horizontal, 20)

                        Spacer(minLength: 40)
                    }
                }
            }

            if showCopied {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill").font(.system(size: 16, weight: .semibold))
                        Text("Copied!").font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "0F172A"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color(hex: "CDFF00")))
                    .padding(.bottom, 40)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation { showCopied = false }
                    }
                }
            }
        }
    }
}

struct MockInfoMiniCard: View {
    let label: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
                .foregroundColor(Color(hex: "71717A"))
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "27272A")))
    }
}

struct MockTechInfoRow: View {
    let label: String
    let value: String
    let onCopy: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.5)
                    .foregroundColor(Color(hex: "71717A"))
                Text(value)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            Spacer()
            Button(action: onCopy) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "CDFF00"))
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Color(hex: "CDFF00").opacity(0.15)))
            }
        }
        .padding(14)
    }
}

struct MockInstallStep: View {
    let number: Int
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(Color(hex: "CDFF00")).frame(width: 26, height: 26)
                Text("\(number)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "0F172A"))
            }
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "71717A"))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Mock Support View

struct MockSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedFAQ: Int? = nil

    let faqs = [
        ("How do I install my eSIM?", "Open your Camera app and scan the QR code. Tap the notification and follow on-screen instructions."),
        ("When does my eSIM activate?", "Your eSIM activates automatically when you connect to a supported network."),
        ("My eSIM is not activating?", "1. Ensure you're in the coverage area\n2. Check eSIM is enabled in Settings\n3. Restart your device"),
        ("Can I use it on multiple devices?", "No, each eSIM is tied to a single device. Purchase separate plans for each."),
        ("What is your refund policy?", "Full refunds within 24 hours if the eSIM has not been activated.")
    ]

    var body: some View {
        ZStack {
            Color(hex: "09090B").ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color(hex: "18181B")))
                    }
                    Spacer()
                    Text("SUPPORT")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(Color(hex: "52525B"))
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
                                    .fill(Color(hex: "CDFF00").opacity(0.15))
                                    .frame(width: 72, height: 72)
                                Image(systemName: "headphones")
                                    .font(.system(size: 30, weight: .semibold))
                                    .foregroundColor(Color(hex: "CDFF00"))
                            }
                            VStack(spacing: 6) {
                                Text("How can we help?")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Find answers or contact us")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "52525B"))
                            }
                        }
                        .padding(.top, 20)

                        HStack(spacing: 12) {
                            MockContactCard(icon: "envelope.fill", title: "EMAIL", subtitle: "support@dxb.com")
                            MockContactCard(icon: "message.fill", title: "WHATSAPP", subtitle: "Chat with us")
                        }
                        .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 14) {
                            Text("FREQUENTLY ASKED")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(Color(hex: "52525B"))
                                .padding(.horizontal, 20)

                            VStack(spacing: 10) {
                                ForEach(Array(faqs.enumerated()), id: \.offset) { index, faq in
                                    MockFAQCard(
                                        question: faq.0,
                                        answer: faq.1,
                                        isExpanded: expandedFAQ == index
                                    ) {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                            expandedFAQ = expandedFAQ == index ? nil : index
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
        }
    }
}

struct MockContactCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "CDFF00"))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "0F172A"))
            }
            VStack(spacing: 3) {
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundColor(Color(hex: "52525B"))
                Text(subtitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "18181B"))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "27272A"), lineWidth: 1))
        )
    }
}

struct MockFAQCard: View {
    let question: String
    let answer: String
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    Text(question)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isExpanded ? Color(hex: "CDFF00") : Color(hex: "52525B"))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(16)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Text(answer)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "71717A"))
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "18181B"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isExpanded ? Color(hex: "CDFF00").opacity(0.3) : Color(hex: "27272A"), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview

#Preview("Design Showcase") {
    DesignShowcaseView()
}

#Preview("Auth") {
    MockAuthView(showAuth: .constant(true))
        .preferredColorScheme(.dark)
}

#Preview("Dashboard") {
    MockDashboardView()
        .preferredColorScheme(.dark)
}

#Preview("Explore") {
    MockExploreView()
        .preferredColorScheme(.dark)
}

#Preview("My eSIMs") {
    MockMyESIMsView()
        .preferredColorScheme(.dark)
}

#Preview("Profile") {
    MockProfileView()
        .preferredColorScheme(.dark)
}

#Preview("Plan Detail") {
    MockPlanDetailView()
        .preferredColorScheme(.dark)
}

#Preview("eSIM Detail") {
    MockESIMDetailView()
        .preferredColorScheme(.dark)
}

#Preview("Checkout") {
    MockCheckoutView(showSuccess: .constant(false))
        .preferredColorScheme(.dark)
}

#Preview("Payment Success") {
    MockPaymentSuccessView(showSuccess: .constant(true))
        .preferredColorScheme(.dark)
}

#Preview("Support") {
    MockSupportView()
        .preferredColorScheme(.dark)
}
