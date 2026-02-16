import SwiftUI

struct AdminAuditLogsView: View {
    var body: some View {
        VStack {
            Text("Audit Logs")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Audit logs viewer coming soon")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    AdminAuditLogsView()
}
