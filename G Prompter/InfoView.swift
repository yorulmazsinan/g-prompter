import SwiftUI

struct InfoView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Arka plan:
                BackgroundView()
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Uygulama Hakkında
                        SectionView(
                            title: "Uygulama Hakkında",
                            content: "G Prompter, içerik üreticileri, konuşmacılar, eğitmenler ve video sunum yapan herkes için tasarlanmış yenilikçi bir teleprompter uygulamasıdır. Metinlerinizi hızlı, etkili ve profesyonel bir şekilde sunmanızı sağlar. Her seviyeden kullanıcı için ideal bir çözümdür."
                        )
                        
                        // Nasıl Kullanılır?
                        SectionView(
                            title: "Nasıl Kullanılır?",
                            content: "Giriş ekranındaki \"Ayarlar\" sayfasından okumak istediğiniz metni, yazı boyutunuzu ve akış hızını seçtikten sonra yapmanız gereken tek şey, kamerayı açıp kayda başlamak!"
                        )
                        
                        // Politikalar
                        SectionView(
                            title: "Politikalar",
                            content: "Gizlilik Politikası ve Kullanım Şartları gibi detayları aşağıdaki butonlarda bulabilirsiniz."
                        )
                        
                        // Geliştirici'ye Nasıl Ulaşırım?
                        SectionView(
                            title: "Geliştirici'ye Nasıl Ulaşırım?",
                            content: "Uygulama hakkında geri bildirim yapmak, istek veya talep durumlarınız için info@sinanyorulmaz.com adresine e-posta gönderebilirsiniz."
                        )
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
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

                    // Gizlilik Politikası
                    NavigationCircleButton(
                        iconName: "shield.lefthalf.fill",
                        destination: {
                            PrivacyPolicyView()
                        }
                    )

                    // Kullanım Şartları
                    NavigationCircleButton(
                        iconName: "doc.text",
                        destination: {
                            TermsOfUseView()
                        }
                    )


                }
                .padding(20)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle("Bilgiler")
        .navigationBarBackButtonHidden()
    }
}


struct SectionView: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(content)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
