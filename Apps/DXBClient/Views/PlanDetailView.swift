import SwiftUI
import SafariServices
import DXBCore

struct PlanDetailView: View {
    let plan: Plan
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = PlanDetailViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(plan.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(plan.priceUSD.formattedPrice)
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Divider()
                
                // Details
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(icon: "antenna.radiowaves.left.and.right", title: "Data", value: "\(plan.dataGB) GB")
                    DetailRow(icon: "calendar", title: "Duration", value: "\(plan.durationDays) days")
                    DetailRow(icon: "speedometer", title: "Speed", value: plan.speed)
                    DetailRow(icon: "map", title: "Coverage", value: plan.coverage.joined(separator: ", "))
                    DetailRow(icon: "chart.bar", title: "Fair Usage", value: "\(plan.fairUsageGB) GB")
                }
                
                Divider()
                
                // Compatibility
                VStack(alignment: .leading, spacing: 8) {
                    Text("Device Compatibility")
                        .font(.headline)
                    
                    Text("Compatible with iPhone XS and later models that support eSIM technology.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if !viewModel.isDeviceCompatible {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Your device may not support eSIM")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(.top, 4)
                    }
                }
                
                Divider()
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.headline)
                    
                    Text(plan.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 100)
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                Task {
                    await viewModel.checkout(plan: plan, apiService: coordinator.currentAPIService)
                }
            } label: {
                Text("Buy Now")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -2)
            .disabled(viewModel.isLoading)
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .sheet(isPresented: $viewModel.showCheckout) {
            if let url = viewModel.checkoutURL {
                SafariView(url: url)
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3))
            }
        }
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Safari View

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - ViewModel

@MainActor
final class PlanDetailViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showCheckout = false
    @Published var checkoutURL: URL?
    @Published var isDeviceCompatible = true
    
    init() {
        checkDeviceCompatibility()
    }
    
    private func checkDeviceCompatibility() {
        // Check if device supports eSIM (iPhone XS and later)
        // This is a simplified check
        #if targetEnvironment(simulator)
        isDeviceCompatible = true
        #else
        if #available(iOS 16.0, *) {
            isDeviceCompatible = true
        } else {
            isDeviceCompatible = false
        }
        #endif
    }
    
    func checkout(plan: Plan, apiService: DXBAPIServiceProtocol) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let idempotencyKey = UUID().uuidString
            let response = try await apiService.createPaymentIntent(
                planId: plan.id,
                promoCode: nil,
                idempotencyKey: idempotencyKey
            )
            
            guard let url = URL(string: response.stripeCheckoutURL) else {
                throw APIError.invalidURL
            }
            
            checkoutURL = url
            showCheckout = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    NavigationStack {
        PlanDetailView(plan: .mock3Days)
            .environmentObject(AppCoordinator())
    }
}
