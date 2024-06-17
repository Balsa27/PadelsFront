import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var  appState: AppState
    var body: some View {
        VStack {
            Spacer()
            
            Button("Log out") {
                appState.isLoading = true
                NavigationUtil.popToRootView(animated: true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    appState.isLoading = false
                }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
