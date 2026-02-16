import SwiftUI

struct AdminFinanceView: View {
    var body: some View {
        VStack {
            Text("Finance & Reports")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Financial reports coming soon")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    AdminFinanceView()
}
