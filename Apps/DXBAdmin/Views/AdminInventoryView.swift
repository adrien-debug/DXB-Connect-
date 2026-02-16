import SwiftUI

struct AdminInventoryView: View {
    var body: some View {
        VStack {
            Text("Inventory Management")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("eSIM profiles inventory coming soon")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    AdminInventoryView()
}
