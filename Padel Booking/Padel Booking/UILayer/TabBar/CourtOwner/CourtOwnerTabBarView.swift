import SwiftUI

struct CourtOwnerTabBarView: View {
    var body: some View {
        TabView {
            CourtOwnerBookingsView()
                .tabItem {
                    Label("Bookings", systemImage: "calendar")
                }
                .font(.headline)
            
            CourtOwnerRequestsView()
                .tabItem {
                    Label("Requests", systemImage: "bell")
                }
                .font(.headline)
            
            CourtOwnerAccountView()
                .tabItem {
                    Label("Account", systemImage: "person.circle")
                }
                .font(.headline)
            
        }
        .accentColor(Color("primaryGreen"))
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    NavigationStack {
        CourtOwnerTabBarView()
    }
}
