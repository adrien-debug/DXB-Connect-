import SwiftUI
import DXBCore

struct AdminOrdersView: View {
    @StateObject private var viewModel = AdminOrdersViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                TextField("Search orders...", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 300)
                
                Picker("Status", selection: $viewModel.selectedStatus) {
                    Text("All").tag(nil as OrderStatus?)
                    ForEach([OrderStatus.pending, .paid, .delivered, .failed, .refunded], id: \.self) { status in
                        Text(status.rawValue).tag(status as OrderStatus?)
                    }
                }
                .frame(width: 150)
                
                Spacer()
                
                Button {
                    viewModel.exportCSV()
                } label: {
                    Label("Export CSV", systemImage: "square.and.arrow.up")
                }
            }
            .padding()
            .background(Color(.windowBackgroundColor))
            
            Divider()
            
            // Orders Table
            Table(viewModel.filteredOrders, selection: $viewModel.selectedOrder) {
                TableColumn("Order ID", value: \.id) { order in
                    Text(order.id.prefix(8))
                }
                
                TableColumn("User") { order in
                    Text("user@example.com") // TODO
                }
                
                TableColumn("Plan", value: \.plan.name)
                
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
            .contextMenu(forSelectionType: Order.ID.self) { items in
                if items.count == 1 {
                    Button("View Details") {
                        viewModel.showOrderDetail = true
                    }
                    
                    Divider()
                    
                    Button("Resend QR") {
                        // TODO
                    }
                    
                    Button("Refund") {
                        viewModel.showRefundSheet = true
                    }
                }
            }
        }
        .navigationTitle("Orders")
        .sheet(isPresented: $viewModel.showOrderDetail) {
            if let order = viewModel.filteredOrders.first(where: { $0.id == viewModel.selectedOrder }) {
                AdminOrderDetailView(order: order)
            }
        }
        .sheet(isPresented: $viewModel.showRefundSheet) {
            if let order = viewModel.filteredOrders.first(where: { $0.id == viewModel.selectedOrder }) {
                RefundSheet(order: order)
            }
        }
        .task {
            await viewModel.loadOrders()
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

// MARK: - Order Detail View

struct AdminOrderDetailView: View {
    let order: Order
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Order Information") {
                    LabeledContent("Order ID", value: order.id)
                    LabeledContent("Status", value: order.status.rawValue)
                    LabeledContent("Created", value: order.createdAt.formattedLong)
                }
                
                Section("Plan Details") {
                    LabeledContent("Plan", value: order.plan.name)
                    LabeledContent("Data", value: "\(order.plan.dataGB) GB")
                    LabeledContent("Duration", value: "\(order.plan.durationDays) days")
                }
                
                Section("Payment") {
                    LabeledContent("Amount", value: order.amount.formattedPrice)
                    LabeledContent("Currency", value: order.currency)
                }
                
                if let esim = order.esim {
                    Section("eSIM Details") {
                        if let activationCode = esim.activationCode {
                            LabeledContent("Activation Code", value: activationCode)
                        }
                        if let smdpAddress = esim.smdpAddress {
                            LabeledContent("SM-DP+ Address", value: smdpAddress)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Order Details")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 600, height: 500)
    }
}

// MARK: - Refund Sheet

struct RefundSheet: View {
    let order: Order
    @Environment(\.dismiss) private var dismiss
    @State private var amount: String = ""
    @State private var reason: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Refund Amount") {
                    TextField("Amount", text: $amount)
                    Text("Original amount: \(order.amount.formattedPrice)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Reason") {
                    TextEditor(text: $reason)
                        .frame(height: 100)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Refund Order")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Refund") {
                        // TODO: Process refund
                        dismiss()
                    }
                    .disabled(amount.isEmpty || reason.isEmpty)
                }
            }
        }
        .frame(width: 500, height: 400)
        .onAppear {
            amount = String(describing: order.amount)
        }
    }
}

// MARK: - ViewModel

@MainActor
final class AdminOrdersViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var searchText = ""
    @Published var selectedStatus: OrderStatus?
    @Published var selectedOrder: Order.ID?
    @Published var showOrderDetail = false
    @Published var showRefundSheet = false
    
    var filteredOrders: [Order] {
        orders.filter { order in
            let matchesSearch = searchText.isEmpty || order.id.localizedCaseInsensitiveContains(searchText)
            let matchesStatus = selectedStatus == nil || order.status == selectedStatus
            return matchesSearch && matchesStatus
        }
    }
    
    func loadOrders() async {
        // Mock data
        orders = Order.mockOrders
    }
    
    func exportCSV() {
        // TODO: Implement CSV export
        print("Exporting CSV...")
    }
}

#Preview {
    AdminOrdersView()
}
