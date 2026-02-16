import SwiftUI
import DXBCore

struct MyESIMsView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = MyESIMsViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading your eSIMs...")
                } else if let error = viewModel.error {
                    ErrorView(message: error) {
                        Task {
                            await viewModel.loadOrders(apiService: coordinator.currentAPIService)
                        }
                    }
                } else if viewModel.orders.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(viewModel.orders) { order in
                            NavigationLink(value: order) {
                                OrderRow(order: order)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("My eSIMs")
            .navigationDestination(for: Order.self) { order in
                ESIMDetailView(order: order)
            }
            .task {
                await viewModel.loadOrders(apiService: coordinator.currentAPIService)
            }
            .refreshable {
                await viewModel.loadOrders(apiService: coordinator.currentAPIService)
            }
        }
    }
}

// MARK: - Order Row

struct OrderRow: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(order.plan.name)
                    .font(.headline)
                
                Spacer()
                
                StatusBadge(status: order.status)
            }
            
            HStack {
                Text("Order #\(order.id.prefix(8))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(order.createdAt.formattedShort)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let usage = order.esim?.usage {
                ProgressView(value: usage.usagePercentage) {
                    HStack {
                        Text("\(usage.dataUsedMB) MB / \(usage.dataTotalMB) MB")
                            .font(.caption)
                        Spacer()
                        Text("\(Int(usage.usagePercentage * 100))%")
                            .font(.caption)
                    }
                }
                .tint(usageColor(for: usage.usagePercentage))
            }
        }
        .padding(.vertical, 4)
    }
    
    private func usageColor(for percentage: Double) -> Color {
        if percentage < 0.7 {
            return .green
        } else if percentage < 0.9 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: OrderStatus
    
    var body: some View {
        Text(statusText)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(8)
    }
    
    private var statusText: String {
        switch status {
        case .pending: return "Pending"
        case .paid: return "Paid"
        case .fulfilling: return "Preparing"
        case .delivered: return "Ready"
        case .active: return "Active"
        case .expired: return "Expired"
        case .failed: return "Failed"
        case .refunded: return "Refunded"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .pending, .paid, .fulfilling: return .orange
        case .delivered, .active: return .green
        case .expired, .failed, .refunded: return .red
        }
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "simcard")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No eSIMs Yet")
                .font(.headline)
            
            Text("Purchase your first eSIM to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - ViewModel

@MainActor
final class MyESIMsViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isLoading = false
    @Published var error: String?
    
    func loadOrders(apiService: DXBAPIServiceProtocol) async {
        isLoading = true
        error = nil
        
        do {
            let response = try await apiService.fetchOrders(status: nil, limit: 100, offset: 0)
            orders = response.orders.sorted { $0.createdAt > $1.createdAt }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        MyESIMsView()
            .environmentObject(AppCoordinator())
    }
}
