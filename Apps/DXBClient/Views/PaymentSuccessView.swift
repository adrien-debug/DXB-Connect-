import SwiftUI
import DXBCore

struct PaymentSuccessView: View {
    let plan: Plan
    let onDismiss: () -> Void
    
    @State private var showCheckmark = false
    @State private var showContent = false
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            // Background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Success Animation
                ZStack {
                    // Pulse circles
                    Circle()
                        .stroke(AppTheme.textPrimary.opacity(0.1), lineWidth: 2)
                        .frame(width: 160, height: 160)
                        .scaleEffect(pulseAnimation ? 1.3 : 1)
                        .opacity(pulseAnimation ? 0 : 1)
                    
                    Circle()
                        .stroke(AppTheme.textPrimary.opacity(0.2), lineWidth: 2)
                        .frame(width: 140, height: 140)
                        .scaleEffect(pulseAnimation ? 1.2 : 1)
                        .opacity(pulseAnimation ? 0 : 1)
                    
                    // Main circle
                    Circle()
                        .fill(AppTheme.textPrimary)
                        .frame(width: 120, height: 120)
                        .shadow(color: AppTheme.textPrimary.opacity(0.3), radius: 20, y: 10)
                    
                    // Checkmark
                    Image(systemName: "checkmark")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(showCheckmark ? 1 : 0)
                        .opacity(showCheckmark ? 1 : 0)
                }
                
                // Text Content
                VStack(spacing: 16) {
                    Text("Payment Successful!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("Your eSIM is being activated")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.textTertiary)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                // Order Summary Card
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(plan.name)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text(plan.location)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textTertiary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(plan.dataGB) GB")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text("\(plan.durationDays) days")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textTertiary)
                        }
                    }
                    
                    Rectangle()
                        .fill(AppTheme.border)
                        .frame(height: 1)
                    
                    HStack {
                        Text("Total Paid")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Spacer()
                        
                        Text(plan.priceUSD.formattedPrice)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppTheme.border, lineWidth: 1.5)
                        )
                )
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                Spacer()
                
                // CTA Button
                Button {
                    onDismiss()
                } label: {
                    HStack(spacing: 10) {
                        Text("VIEW MY eSIMs")
                            .font(.system(size: 14, weight: .bold))
                            .tracking(1)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppTheme.textPrimary)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            // Animate checkmark
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) {
                showCheckmark = true
            }
            
            // Animate content
            withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
                showContent = true
            }
            
            // Start pulse animation
            withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                pulseAnimation = true
            }
        }
    }
}

#Preview {
    PaymentSuccessView(
        plan: Plan(
            id: "1",
            name: "Dubai Starter",
            description: "Perfect for short trips",
            dataGB: 5,
            durationDays: 7,
            priceUSD: 9.99,
            speed: "4G/LTE",
            location: "United Arab Emirates",
            locationCode: "AE"
        ),
        onDismiss: {}
    )
}
