import SwiftUI
import Combine

struct CourtOwnerAccountView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    var body: some View {
        VStack {
            headerView
            contentView
            
            Spacer()
        }
        .ignoresSafeArea(edges: .top)
    }
    
    var headerView: some View {
        VStack {
            HStack(spacing: 20) {
                Text("CourtOwner")
                
                Spacer()
                
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemSymbol: .gear)
                        .foregroundColor(.black)
                        .font(.title)
                        .padding(.trailing)
                }
            }
            
            HStack {
                Image(systemSymbol: .personCircleFill)
                    .resizable()
                    .frame(width: 85, height: 85)
                    .padding(.trailing)
                
                Spacer()
                HStack(spacing: 50) {
                    VStack {
                        Text("Bookings")
                        Text("127")
                    }
                    
                    VStack {
                        Text("Requests")
                        Text("13")
                    }
                }
                Spacer()
            }
            .padding(.vertical)
            
        }
        .padding(.top, safeAreaInsets.top + 10)
        .padding([.bottom, .leading])
        .background(Color("tabBarBackgroundColor"))
    }
    
    var contentView: some View {
        VStack(alignment: .leading) {
            Text("Court list")
                .padding()
                .font(.headline)
                .bold()
                .fontDesign(.rounded)
            
            CourtsListView()
        }
    }
}

#Preview {
    CourtOwnerAccountView()
}
