import SwiftUI
import DXBCore

struct SupportView: View {
    var prefilledOrderId: String? = nil
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = SupportViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                Section("FAQ") {
                    ForEach(FAQItem.allItems) { item in
                        DisclosureGroup {
                            Text(item.answer)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                        } label: {
                            Text(item.question)
                                .font(.subheadline)
                        }
                    }
                }
                
                Section("Contact Us") {
                    Button {
                        viewModel.showContactForm = true
                    } label: {
                        Label("Send Message", systemImage: "envelope")
                    }
                    
                    Link(destination: URL(string: "mailto:support@dxbconnect.com")!) {
                        Label("Email Support", systemImage: "envelope.fill")
                    }
                }
                
                if !viewModel.tickets.isEmpty {
                    Section("My Tickets") {
                        ForEach(viewModel.tickets) { ticket in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(ticket.subject)
                                    .font(.subheadline)
                                
                                HStack {
                                    Text(ticket.id)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text(ticket.status.uppercased())
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(ticket.status == "open" ? .orange : .green)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Support")
            .sheet(isPresented: $viewModel.showContactForm) {
                ContactFormView(prefilledOrderId: prefilledOrderId)
            }
            .task {
                await viewModel.loadTickets(apiService: coordinator.currentAPIService)
            }
        }
    }
}

// MARK: - FAQ Item

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    
    static let allItems = [
        FAQItem(
            question: "How do I install my eSIM?",
            answer: "Open your Camera app and scan the QR code. Tap the notification that appears and follow the on-screen instructions. Your eSIM will be installed in Settings > Cellular."
        ),
        FAQItem(
            question: "When does my eSIM activate?",
            answer: "Your eSIM activates automatically when you connect to a supported network in Dubai. Make sure to enable the eSIM in your cellular settings."
        ),
        FAQItem(
            question: "My eSIM is not activating. What should I do?",
            answer: "1. Ensure you're in Dubai or UAE\n2. Check that the eSIM is enabled in Settings > Cellular\n3. Restart your device\n4. If issue persists, contact support"
        ),
        FAQItem(
            question: "Can I use my eSIM in multiple devices?",
            answer: "No, each eSIM is tied to a single device. If you need eSIMs for multiple devices, please purchase separate plans."
        ),
        FAQItem(
            question: "What is your refund policy?",
            answer: "We offer full refunds within 24 hours of purchase if the eSIM has not been activated. After activation, refunds are not available."
        ),
        FAQItem(
            question: "How do I check my data usage?",
            answer: "You can view your data usage in the 'My eSIMs' tab. Usage updates every few hours. You can also check in your device's Settings > Cellular."
        )
    ]
}

// MARK: - Contact Form

struct ContactFormView: View {
    var prefilledOrderId: String? = nil
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = ContactFormViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Subject") {
                    TextField("Brief description of your issue", text: $viewModel.subject)
                }
                
                Section("Message") {
                    TextEditor(text: $viewModel.message)
                        .frame(minHeight: 150)
                }
                
                Section("Order ID (Optional)") {
                    TextField("Order ID", text: $viewModel.orderId)
                }
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") {
                        Task {
                            await viewModel.sendTicket(
                                apiService: coordinator.currentAPIService,
                                dismiss: dismiss
                            )
                        }
                    }
                    .disabled(!viewModel.isValid || viewModel.isLoading)
                }
            }
            .alert("Success", isPresented: $viewModel.showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your message has been sent. We'll respond within 24 hours.")
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .onAppear {
                if let orderId = prefilledOrderId {
                    viewModel.orderId = orderId
                }
            }
        }
    }
}

// MARK: - ViewModels

@MainActor
final class SupportViewModel: ObservableObject {
    @Published var tickets: [Ticket] = []
    @Published var showContactForm = false
    
    func loadTickets(apiService: DXBAPIServiceProtocol) async {
        do {
            tickets = try await apiService.fetchTickets()
        } catch {
            print("Failed to load tickets: \(error)")
        }
    }
}

@MainActor
final class ContactFormViewModel: ObservableObject {
    @Published var subject = ""
    @Published var message = ""
    @Published var orderId = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showSuccess = false
    
    var isValid: Bool {
        !subject.isEmpty && !message.isEmpty
    }
    
    func sendTicket(apiService: DXBAPIServiceProtocol, dismiss: DismissAction) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            _ = try await apiService.createTicket(
                subject: subject,
                message: message,
                orderId: orderId.isEmpty ? nil : orderId
            )
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    SupportView()
        .environmentObject(AppCoordinator())
}
