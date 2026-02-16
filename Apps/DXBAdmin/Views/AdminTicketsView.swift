import SwiftUI

struct AdminTicketsView: View {
    var body: some View {
        VStack {
            Text("Support Tickets")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Tickets management coming soon")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    AdminTicketsView()
}
