import SwiftUI
import FirebaseMessaging

struct ContentView: View {
    @AppStorage("inputText") private var inputText: String = "Buraya, video kaydınız sırasında ekranda aşağı doğru kaymasını istediğiniz bir okuma metni girebilirsiniz. Gördüğünüz bu metin, bir örnek niteliği taşıyıp, dilediğiniz zaman silebilir veya değiştirebilirsiniz."
    @AppStorage("readingSpeed") private var readingSpeed: Double = 2.2
    @AppStorage("fontSize") private var fontSize: Double = 35

    var body: some View {
        NavigationView {
            ZStack {
                // Arka plan:
                BackgroundView()

                // İçerik:
                VStack() {
                    Spacer()
                    
                    // Başlık ve açıklama:
                    VStack(spacing: 10) {
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 200)
                            .padding(.top, 50)
                            .onAppear(perform: fetchFCMToken)

                        Text("Metninizi okuyarak video kaydı yapabileceğiniz pratik bir uygulama.")
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                    }

                    Spacer()

                    // Alt butonlar:
                    HStack(spacing: 15) {
                        // Ayarlar:
                        NavigationCircleButton(
                            iconName: "gear",
                            destination: {
                                PrompterSetupView()
                            }
                        )
                        
                        // Bilgilendirme:
                        NavigationCircleButton(
                            iconName: "info",
                            iconSize: 27,
                            destination: {
                                InfoView()
                            }
                        )

                        Spacer()

                        // Kamera:
                        NavigationCircleButton(
                            iconName: "camera",
                            iconSize: 23,
                            backgroundColor: Color(hex: "#32CD32"),
                            iconColor: .white,
                            destination: {
                                RecordingView(text: inputText, readingSpeed: readingSpeed, fontSize: fontSize)
                            }
                        )

                    }
                    .padding(20)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .navigationBarTitle("G Prompter", displayMode: .inline)
            .navigationBarHidden(true)
        }
        .accentColor(Color(hex: "#32CD32"))
    }

    private func fetchFCMToken() {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("FCM Token alma hatası: \(error.localizedDescription)")
            } else if let token = token {
                print("FCM Token: \(token)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
