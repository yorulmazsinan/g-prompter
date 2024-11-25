import MarkdownUI
import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    @State private var policyText: String = "Yükleniyor..."
    @State private var isLoading: Bool = true // Yükleme durumu
    @State private var hasError: Bool = false // Hata durumu
    
    private let url = URL(string: "https://raw.githubusercontent.com/yorulmazsinan/g-prompter/main/privacy-policy.md")!

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Arka plan:
                BackgroundView()
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    if isLoading {
                        // Yüklenme sırasında gösterilen içerik:
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                        }
                        .padding(20)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    } else {
                        VStack(alignment: .leading, spacing: 20) {
                            Markdown(policyText)
                                .markdownTextStyle(\.text) {
                                    ForegroundColor(Color.white)
                                }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .onAppear {
                    DispatchQueue.global(qos: .background).async {
                        fetchPolicy()
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
                }
                .padding(20)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle("Gizlilik Politikası")
        .navigationBarBackButtonHidden()
    }
    
    func fetchPolicy() {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print("Ağ hatası: \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    self.policyText = "Gizlilik politikası yüklenemedi."
                    self.isLoading = false
                }
                return
            }
            
            if let data = data, let text = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.policyText = text
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.policyText = "Geçersiz veri alındı."
                    self.isLoading = false
                }
            }
        }
        task.resume()
    }

}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
