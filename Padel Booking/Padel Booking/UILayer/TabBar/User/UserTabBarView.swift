import SwiftUI

struct UserTabBarView: View {
    var body: some View {
        TabView {
            UserBookingsView()
                .tabItem {
                    Label("Bookings", systemImage: "calendar")
                }
            
            CourtOwnerAccountView()
                .tabItem {
                    Label("Account", systemImage: "person.circle")
                }
        }
        .accentColor(Color("primaryGreen"))
        .navigationBarBackButtonHidden()
    }
}

struct UserTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        UserTabBarView()
    }
}
