import SwiftUI

struct PrompterSetupView: View {
    @StateObject private var keyboardResponder = KeyboardResponder()
    
    @AppStorage("inputText") private var inputText: String = "Buraya, video kaydınız sırasında ekranda aşağı doğru kaymasını istediğiniz bir okuma metni girebilirsiniz. Gördüğünüz bu metin, bir örnek niteliği taşıyıp, dilediğiniz zaman silebilir veya değiştirebilirsiniz."
    @AppStorage("readingSpeed") private var readingSpeed: Double = 2.6
    @AppStorage("fontSize") private var fontSize: Double = 42
    
    @FocusState private var isTextEditorFocused: Bool
    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Arka plan:
                BackgroundView()
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Metin başlığı ve giriş
                        TextEditorSectionView(title: "Metin", content: $inputText, fontSize: CGFloat(fontSize))

                        // Yazı boyutu
                        SliderControlSectionView(
                            title: "Yazı Boyutu (\(String(format: "%.0f", fontSize))px)",
                            value: $fontSize,
                            range: 20...60
                        )

                        // Okuma hızı
                        SliderControlSectionView(
                            title: "Okuma Hızı (\(String(format: "%.1f", readingSpeed))x)",
                            value: $readingSpeed,
                            range: 1.0...5.0
                        )
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Klavye açıkken kapat butonu
                if keyboardResponder.isKeyboardVisible {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button("Kapat") {
                                isTextEditorFocused = false
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .padding(.trailing, 16)
                        }
                    }
                }
            }
            
            // Alt kontrol butonları:
            VStack {
                Spacer()
                
                HStack(spacing: 15) {
                    // Geri:
                    ActionCircleButton(
                        iconName: "chevron.backward",
                        iconSize: 22,
                        action: {
                            dismiss()
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
        .edgesIgnoringSafeArea(.bottom)
        .ignoresSafeArea(.keyboard)
        .navigationTitle("Prompter Ayarları")
        .navigationBarBackButtonHidden()
    }
}

// Metin başlığı ve metin giriş alanı
struct TextEditorSectionView: View {
    let title: String
    @Binding var content: String
    let fontSize: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Başlık
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)

            // Metin düzenleyici
            CustomTextEditor(
                text: $content,
                font: UIFont.systemFont(ofSize: fontSize),
                textColor: .white,
                alignment: .center
            )
            .frame(height: 270)
            .padding(.horizontal, 20)
            .background(Color.black.cornerRadius(10)) // Daha basit yapı
        }
    }
}

// Slider ayar bölümü
struct SliderControlSectionView: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    
    // Renkleri üstte hesaplayarak optimize ettik
    private let thumbColor = UIColor(hex: "#32CD32") ?? .green
    private let minimumTrackColor = UIColor.white
    private let maximumTrackColor = UIColor.gray

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)

            CustomSlider(
                value: $value,
                range: range,
                thumbColor: UIColor(hex: "#32CD32") ?? .green,
                minimumTrackColor: .white,
                maximumTrackColor: .gray
            )
            .frame(height: 25)
        }
    }
}

struct PrompterSetupView_Previews: PreviewProvider {
    static var previews: some View {
        PrompterSetupView()
    }
}
