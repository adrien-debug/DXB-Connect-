import SwiftUI
import CoreImage.CIFilterBuiltins
import DXBCore

struct ESIMDetailView: View {
    let order: Order
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = ESIMDetailViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Status
                HStack {
                    Text("Status")
                        .font(.headline)
                    
                    Spacer()
                    
                    StatusBadge(status: order.status)
                }
                
                Divider()
                
                // QR Code (if available)
                if let esim = order.esim, order.status == .delivered || order.status == .active {
                    VStack(spacing: 16) {
                        Text("Scan to Install")
                            .font(.headline)
                        
                        if let activationCode = esim.activationCode {
                            QRCodeView(text: activationCode)
                                .frame(width: 250, height: 250)
                        }
                        
                        Text("Scan this QR code with your device's Camera app to install the eSIM")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button {
                            viewModel.showInstructions = true
                        } label: {
                            Label("Installation Instructions", systemImage: "info.circle")
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    Divider()
                    
                    // Manual Installation
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Manual Installation")
                            .font(.headline)
                        
                        if let smdpAddress = esim.smdpAddress {
                            InfoRow(title: "SM-DP+ Address", value: smdpAddress)
                        }
                        
                        if let activationCode = esim.activationCode {
                            InfoRow(title: "Activation Code", value: activationCode)
                        }
                    }
                    
                    Divider()
                }
                
                // Usage (if available)
                if let usage = order.esim?.usage {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Data Usage")
                            .font(.headline)
                        
                        ProgressView(value: usage.usagePercentage) {
                            HStack {
                                Text("\(usage.dataUsedMB) MB used")
                                Spacer()
                                Text("\(usage.dataTotalMB) MB total")
                            }
                            .font(.subheadline)
                        }
                        .tint(usageColor(for: usage.usagePercentage))
                        
                        Text("Last updated: \(usage.lastUpdated.relativeFormatted)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                }
                
                // Order Details
                VStack(alignment: .leading, spacing: 12) {
                    Text("Order Details")
                        .font(.headline)
                    
                    InfoRow(title: "Order ID", value: order.id)
                    InfoRow(title: "Plan", value: order.plan.name)
                    InfoRow(title: "Amount", value: order.amount.formattedPrice)
                    InfoRow(title: "Date", value: order.createdAt.formattedLong)
                }
                
                Divider()
                
                // Actions
                VStack(spacing: 12) {
                    if order.status == .delivered || order.status == .active {
                        Button {
                            Task {
                                await viewModel.resendQR(orderId: order.id, apiService: coordinator.currentAPIService)
                            }
                        } label: {
                            Label("Resend QR Code", systemImage: "arrow.clockwise")
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                        }
                        .buttonStyle(.bordered)
                        .disabled(viewModel.isLoading)
                    }
                    
                    NavigationLink {
                        SupportView(prefilledOrderId: order.id)
                    } label: {
                        Label("Need Help?", systemImage: "questionmark.circle")
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .navigationTitle("eSIM Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Success", isPresented: $viewModel.showSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("QR code has been resent to your email")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .sheet(isPresented: $viewModel.showInstructions) {
            InstallationInstructionsView()
        }
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

// MARK: - QR Code View

struct QRCodeView: View {
    let text: String
    
    var body: some View {
        if let qrImage = generateQRCode(from: text) {
            Image(uiImage: qrImage)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .overlay {
                    Text("QR Code Unavailable")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
        }
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        
        guard let outputImage = filter.outputImage else { return nil }
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: transform)
        
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .textSelection(.enabled)
        }
    }
}

// MARK: - Installation Instructions

struct InstallationInstructionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    InstructionStep(
                        number: 1,
                        title: "Open Camera App",
                        description: "Open your device's Camera app and point it at the QR code"
                    )
                    
                    InstructionStep(
                        number: 2,
                        title: "Tap Notification",
                        description: "Tap the notification that appears at the top of your screen"
                    )
                    
                    InstructionStep(
                        number: 3,
                        title: "Add Cellular Plan",
                        description: "Tap 'Add Cellular Plan' and follow the on-screen instructions"
                    )
                    
                    InstructionStep(
                        number: 4,
                        title: "Label Your Plan",
                        description: "Give your eSIM a label (e.g., 'Dubai Travel') for easy identification"
                    )
                    
                    InstructionStep(
                        number: 5,
                        title: "Activate",
                        description: "Your eSIM will activate automatically when you arrive in Dubai"
                    )
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Troubleshooting")
                            .font(.headline)
                        
                        Text("• Make sure your device is connected to Wi-Fi\n• Ensure your device supports eSIM (iPhone XS or later)\n• If QR code doesn't scan, use manual installation")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Installation Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InstructionStep: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text("\(number)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.blue)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - ViewModel

@MainActor
final class ESIMDetailViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showSuccess = false
    @Published var showInstructions = false
    
    func resendQR(orderId: String, apiService: DXBAPIServiceProtocol) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await apiService.resendQR(orderId: orderId)
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    NavigationStack {
        ESIMDetailView(order: .mockDelivered)
            .environmentObject(AppCoordinator())
    }
}
