import SwiftUI
import Charts
import DXBCore

struct AdminDashboardView: View {
    @StateObject private var viewModel = AdminDashboardViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    Text("Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Picker("Period", selection: $viewModel.selectedPeriod) {
                        Text("Today").tag("today")
                        Text("Week").tag("week")
                        Text("Month").tag("month")
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 250)
                }
                
                // KPI Cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    KPICard(
                        title: "Revenue",
                        value: "$12,450",
                        change: "+12%",
                        isPositive: true,
                        icon: "dollarsign.circle.fill"
                    )
                    
                    KPICard(
                        title: "Orders",
                        value: "342",
                        change: "+8%",
                        isPositive: true,
                        icon: "cart.fill"
                    )
                    
                    KPICard(
                        title: "Success Rate",
                        value: "98.2%",
                        change: "+1.2%",
                        isPositive: true,
                        icon: "checkmark.circle.fill"
                    )
                    
                    KPICard(
                        title: "Open Tickets",
                        value: "12",
                        change: "-3",
                        isPositive: true,
                        icon: "questionmark.circle.fill"
                    )
                }
                
                // Charts
                HStack(spacing: 16) {
                    // Revenue Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Revenue Over Time")
                            .font(.headline)
                        
                        Chart(viewModel.revenueData) { item in
                            LineMark(
                                x: .value("Date", item.date),
                                y: .value("Revenue", item.value)
                            )
                            .foregroundStyle(.blue)
                        }
                        .frame(height: 200)
                    }
                    .padding()
                    .background(Color(.windowBackgroundColor))
                    .cornerRadius(12)
                    
                    // Orders by Plan
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Orders by Plan")
                            .font(.headline)
                        
                        Chart(viewModel.ordersByPlan) { item in
                            SectorMark(
                                angle: .value("Count", item.count),
                                innerRadius: .ratio(0.5)
                            )
                            .foregroundStyle(by: .value("Plan", item.plan))
                        }
                        .frame(height: 200)
                    }
                    .padding()
                    .background(Color(.windowBackgroundColor))
                    .cornerRadius(12)
                }
                
                // Recent Orders
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Orders")
                        .font(.headline)
                    
                    Table(viewModel.recentOrders) {
                        TableColumn("Order ID") { order in
                            Text(order.id.prefix(8))
                        }
                        
                        TableColumn("User") { order in
                            Text("user@example.com") // TODO: Add user email to Order model
                        }
                        
                        TableColumn("Plan") { order in
                            Text(order.plan.name)
                        }
                        
                        TableColumn("Amount") { order in
                            Text(order.amount.formattedPrice)
                        }
                        
                        TableColumn("Status") { order in
                            Text(order.status.rawValue)
                                .foregroundColor(statusColor(for: order.status))
                        }
                        
                        TableColumn("Date") { order in
                            Text(order.createdAt.formattedShort)
                        }
                    }
                    .frame(height: 300)
                }
                .padding()
                .background(Color(.windowBackgroundColor))
                .cornerRadius(12)
            }
            .padding()
        }
        .task {
            await viewModel.loadData()
        }
    }
    
    private func statusColor(for status: OrderStatus) -> Color {
        switch status {
        case .pending, .paid, .fulfilling: return .orange
        case .delivered, .active: return .green
        case .expired, .failed, .refunded: return .red
        }
    }
}

// MARK: - KPI Card

struct KPICard: View {
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                    Text(change)
                }
                .font(.caption)
                .foregroundColor(isPositive ? .green : .red)
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(12)
    }
}

// MARK: - ViewModel

@MainActor
final class AdminDashboardViewModel: ObservableObject {
    @Published var selectedPeriod = "week"
    @Published var revenueData: [RevenueDataPoint] = []
    @Published var ordersByPlan: [PlanDataPoint] = []
    @Published var recentOrders: [Order] = []
    
    struct RevenueDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
    }
    
    struct PlanDataPoint: Identifiable {
        let id = UUID()
        let plan: String
        let count: Int
    }
    
    func loadData() async {
        // Mock data
        revenueData = (0..<7).map { day in
            RevenueDataPoint(
                date: Calendar.current.date(byAdding: .day, value: -day, to: Date())!,
                value: Double.random(in: 1000...3000)
            )
        }.reversed()
        
        ordersByPlan = [
            PlanDataPoint(plan: "3 Days", count: 120),
            PlanDataPoint(plan: "7 Days", count: 150),
            PlanDataPoint(plan: "15 Days", count: 72)
        ]
        
        recentOrders = Order.mockOrders
    }
}

#Preview {
    AdminDashboardView()
}
