import Foundation

final class AppState: ObservableObject {
    @Published var isLoading = false
    @Published var toast: Toast.State = .hide

    
    func showToast(withMessage message: String, forError: Bool = false) {
        toast = .show(forError ? .error(message) : .success(message))
    }
    
    func hideToast() {
        toast = .hide
    }
}
