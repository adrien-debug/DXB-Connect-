import SwiftUI

struct Plan: Codable, Identifiable {
    let id: String
    let name: String
    let price: Double
    let features: [String]
}

struct APIResponse<T: Codable>: Codable {
    let data: T
}

struct ContentView: View {
    @State private var plans: [Plan] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Chargement...")
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text(error)
                            .multilineTextAlignment(.center)
                        Button("Réessayer") {
                            loadPlans()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    List(plans) { plan in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(plan.name)
                                    .font(.headline)
                                Spacer()
                                Text("$\(plan.price, specifier: "%.2f")")
                                    .font(.title2)
                                    .bold()
                            }
                            
                            ForEach(plan.features, id: \.self) { feature in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(feature)
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("DXB Admin")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        loadPlans()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear {
            loadPlans()
        }
    }
    
    func loadPlans() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "http://localhost:3001/api/plans") else {
            errorMessage = "URL invalide"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = "Erreur: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    errorMessage = "Aucune donnée reçue"
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(APIResponse<[Plan]>.self, from: data)
                    plans = response.data
                } catch {
                    errorMessage = "Erreur de décodage: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

#Preview {
    ContentView()
}
