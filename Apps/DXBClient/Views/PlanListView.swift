import SwiftUI
import DXBCore

struct PlanListView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = PlanListViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading plans...")
                } else if let error = viewModel.error {
                    ErrorView(message: error) {
                        Task {
                            await viewModel.loadPlans(apiService: coordinator.currentAPIService)
                        }
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.plans) { plan in
                                NavigationLink(value: plan) {
                                    PlanCard(plan: plan)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("eSIM Plans")
            .navigationDestination(for: Plan.self) { plan in
                PlanDetailView(plan: plan)
            }
            .task {
                await viewModel.loadPlans(apiService: coordinator.currentAPIService)
            }
            .refreshable {
                await viewModel.loadPlans(apiService: coordinator.currentAPIService)
            }
        }
    }
}

// MARK: - Plan Card

struct PlanCard: View {
    let plan: Plan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(plan.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(plan.priceUSD.formattedPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("USD")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            HStack(spacing: 24) {
                Label("\(plan.dataGB) GB", systemImage: "antenna.radiowaves.left.and.right")
                Label("\(plan.durationDays) days", systemImage: "calendar")
                Label(plan.speed, systemImage: "speedometer")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - ViewModel

@MainActor
final class PlanListViewModel: ObservableObject {
    @Published var plans: [Plan] = []
    @Published var isLoading = false
    @Published var error: String?
    
    func loadPlans(apiService: DXBAPIServiceProtocol) async {
        isLoading = true
        error = nil
        
        do {
            plans = try await apiService.fetchPlans(locale: "en")
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}

// MARK: - Error View

struct ErrorView: View {
    let message: String
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Retry", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        PlanListView()
            .environmentObject(AppCoordinator())
    }
}
