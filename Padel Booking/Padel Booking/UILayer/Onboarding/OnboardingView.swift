import SwiftUI

struct OnboardingView: View {

    private let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    @State private var selectedIndex = 0

    let images = ["onboarding1", "onboarding2", "onboarding3", "onboarding4"]
    
    let titles = [
        "Effortlessly track your playing history",
        "Gone are the days of uncertainty and long waits",
        "Booking a padel court has never been easier",
        "Modify your plans with ease"
    ]
    
    let descriptions = [
        "Plus, stay organized and ahead of the game with a clear view of your upcoming bookings. ",
        "With our app, you can see which courts are available in real time.",
        "Simply select your preferred date, time, and location, and book the court - it's that straightforward. ",
        "Need to change the date or time of your booking? No problem. "
    ]
    
    var body: some View {
        VStack {
            TabView(selection: $selectedIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                               
                    VStack {
                        Image(images[index])
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 25.0))
                            .scaledToFit()
                            .frame(height: 350)
                            .padding(.horizontal, 20)
                        
                        Text(titles[index])
                            .padding(.horizontal)
                            .padding(.top, 10)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .fontDesign(.monospaced)
                            .font(.headline)
                            .bold()
                        
                        Text(descriptions[index])
                            .padding([.top, .horizontal])
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .fontDesign(.rounded)
                            .font(.subheadline)
                    }
                    
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .onChange(of: selectedIndex) { oldValue, newValue in
                guard newValue <= images.count else {

                    selectedIndex = 0
                    return
                }
              }
            .onReceive(timer) { _ in
                withAnimation {
                  selectedIndex = selectedIndex < images.count ? selectedIndex + 1 : 0
                  }
                }

            Spacer()
            
            VStack(spacing: 20.0) {
                NavigationLink {
                    LoginView()
                } label: {
                    Text("Log in")
                        .primaryButtonTextStyle()
                }

                NavigationLink {
                    SignUpView()
                } label: {
                    Text("Sign up")
                        .font(.system(.headline, design: .monospaced))
                        .fontWeight(.regular)
                        .foregroundStyle(.white)
                }
            }
            .padding()
        }
        .background(Color.black)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
