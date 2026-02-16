import SwiftUI
import DXBCore

struct AdminPlansView: View {
    @StateObject private var viewModel = AdminPlansViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Text("Plans Management")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    viewModel.showAddPlan = true
                } label: {
                    Label("Add Plan", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
            Table(viewModel.plans) {
                TableColumn("Name", value: \.name)
                TableColumn("Data") { plan in
                    Text("\(plan.dataGB) GB")
                }
                TableColumn("Duration") { plan in
                    Text("\(plan.durationDays) days")
                }
                TableColumn("Price") { plan in
                    Text(plan.priceUSD.formattedPrice)
                }
                TableColumn("Status") { plan in
                    Text(plan.active ? "Active" : "Inactive")
                        .foregroundColor(plan.active ? .green : .red)
                }
            }
        }
        .sheet(isPresented: $viewModel.showAddPlan) {
            Text("Add Plan Form") // TODO: Implement
        }
    }
}

@MainActor
final class AdminPlansViewModel: ObservableObject {
    @Published var plans: [Plan] = Plan.mockPlans
    @Published var showAddPlan = false
}

#Preview {
    AdminPlansView()
}
