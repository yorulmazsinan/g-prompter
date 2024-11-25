import SwiftUI
import Combine

class KeyboardResponder: ObservableObject {
    @Published var isKeyboardVisible: Bool = false
    private var cancellable: AnyCancellable?
    
    init() {
        // Klavye açıldığında veya kapandığında değişiklikleri dinle:
        cancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
            .sink { notification in
                self.isKeyboardVisible = notification.name == UIResponder.keyboardWillShowNotification
            }
    }
    
    deinit {
        // Bellek sızıntısını önlemek için aboneliği iptal et:
        cancellable?.cancel()
    }
}
