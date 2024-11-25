import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // FCM Token APNs ile ilişkilendiriliyor
        Messaging.messaging().apnsToken = deviceToken
        print("APNs Token alındı: \(deviceToken)")
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // FCM Token alındığında tetiklenir
        guard let fcmToken = fcmToken else { return }
        print("FCM Token alındı: \(fcmToken)")
        // Bu token backend'e gönderilebilir
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Uygulama ön planda iken gelen bildirimi gösterir
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Kullanıcı bildirime tıkladığında tetiklenir
        print("Bildirim içeriği: \(response.notification.request.content.userInfo)")
        completionHandler()
    }
}
