import SwiftUI

public struct WatchDashboardView: View {
    @StateObject private var watchManager = WatchConnectivityManager.shared
    @State private var isFocusActive: Bool = false
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Watch Hero Badge
                HStack {
                    Image(systemName: "shield.fill")
                        .foregroundColor(ALIVEColor.neonCyan)
                    Text("LVL \(watchManager.receivedHeroLevel)")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                }
                
                // Quick Focus Start
                Button {
                    isFocusActive.toggle()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: isFocusActive ? "pause.fill" : "play.fill")
                            .font(.title2)
                        Text(isFocusActive ? "PAUSE FOCUS" : "25M FOCUS")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(isFocusActive ? ALIVEColor.xpViolet : ALIVEColor.neonCyan)
                    .foregroundColor(isFocusActive ? .white : .black)
                    .cornerRadius(12)
                }
                
                // Safe Bunks Counter
                HStack(spacing: 6) {
                    Image(systemName: "percent")
                        .foregroundColor(ALIVEColor.staminaGreen)
                    Text("SAFE BUNKS: \(watchManager.receivedSafeBunks)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.gray)
                }
                .padding(.top, 4)
            }
            .padding()
        }
    }
}
