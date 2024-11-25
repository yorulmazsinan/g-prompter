import SwiftUI
import FirebaseCore
import FirebaseMessaging

@main
struct G_PrompterApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        // Firebase Başlatma
        FirebaseApp.configure()
        
        // Navigasyon Çubuğu Ayarları
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        let backButtonImage = UIImage(systemName: "chevron.backward")?.withRenderingMode(.alwaysTemplate)
        appearance.setBackIndicatorImage(backButtonImage, transitionMaskImage: backButtonImage)

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(hex: "#32CD32")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    configureNotifications()
                }
        }
    }

    private func configureNotifications() {
        UNUserNotificationCenter.current().delegate = appDelegate

        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("Bildirim izin hatası: \(error.localizedDescription)")
            } else if granted {
                print("Bildirim izni verildi.")
            } else {
                print("Bildirim izni reddedildi.")
            }
        }

        // APNs ile kayıt
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }

        // FCM Delegasyonu
        Messaging.messaging().delegate = appDelegate
    }
}
