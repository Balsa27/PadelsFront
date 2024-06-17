import SwiftUI
import PopupView

@main
struct PadelBookingApp: App {
    @ObservedObject var appState = AppState()
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    init() {
        setTabBarAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                OnboardingView()
            }
            .environmentObject(appState)
            .overlay {
                appState.isLoading ? loaderView : nil
            }
            .toast($appState.toast)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    appState.isLoading = false
                    LocationManager.shared.requestAuthorisation()
                }
            }
        }
    }
    
    var loaderView: some View {
        VStack {
            Spacer()
            
            Image("AppIcon")
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: 25.0))
                .scaledToFit()
                .frame(height: 450)
                .padding(.horizontal, 20)
            
            Text("Loading...")
                .foregroundStyle(.white)
            
            Spacer()
        }
        .background(Color.black)
    }
    
    func setTabBarAppearance() {
        let appearance = UITabBar.appearance()
        appearance.backgroundColor = UIColor(red: 174/255, green: 221/255, blue: 199/255, alpha: 1.0)
        appearance.layer.borderWidth = 0.5
        appearance.layer.borderColor = UIColor.gray.cgColor
        appearance.clipsToBounds = true
        UIDatePicker.appearance().minuteInterval = 30
    }
}
