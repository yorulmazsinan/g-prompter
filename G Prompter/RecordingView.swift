import SwiftUI
import AVFoundation
import Photos

struct RecordingView: View {
    @State private var currentResolutionName: String = "Unknown"
    @State private var isLandscape: Bool = UIDevice.current.orientation.isLandscape
    @State private var isFrontCamera = true
    @State private var isRecording = false
    @State private var offset: CGFloat = 0
    @State private var recordingTime: TimeInterval = 0
    @State private var recordingTimer: Timer? = nil
    @State private var timer: Timer?
    @State private var coordinator: Coordinator?
    @State private var showSaveMessage = false
    @State private var isCameraLoading = true
    
    @Environment(\.dismiss) var dismiss

    let text: String
    let readingSpeed: Double
    let fontSize: Double
    
    var formattedRecordingTime: String {
        let minutes = Int(recordingTime) / 60
        let seconds = Int(recordingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Arka plan:
                BackgroundView()
                    .edgesIgnoringSafeArea(.all)
                
                CameraView(isFrontCamera: $isFrontCamera)
                    .rotationEffect(.degrees(isLandscape ? 270 : 0))
                    .onAppear {
                        isCameraLoading = true // Yükleme durumu başlatılıyor.
                        
                        DispatchQueue.global(qos: .userInitiated).async {
                            DispatchQueue.main.async {
                                isCameraLoading = false // Kamera oturumu başladıktan sonra yükleme durumu sona eriyor.
                            }
                        }
                    }
                    .overlay(
                        Group {
                            if isCameraLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.white.opacity(0.5))
                            }
                        }
                    )
                    .onDisappear {
                        DispatchQueue.global(qos: .userInitiated).async {
                            if CameraManager.shared.session.isRunning {
                                CameraManager.shared.session.stopRunning()
                                print("Kamera oturumu durduruldu.")
                            }
                        }
                    }

                    .ignoresSafeArea()
                
                // Yazıyı okuduğumuz şeffaf kutu alanı:
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.5))
                            .frame(height: geometry.size.height * 0.4)

                        ScrollView(.vertical, showsIndicators: false) {
                            Text(text)
                                .foregroundColor(.white)
                                .font(.system(size: CGFloat(fontSize)))
                                .multilineTextAlignment(.center)
                                .padding(.top, offset)
                                .padding(.bottom, offset)
                                .padding(.horizontal, 20)
                                .onAppear {
                                    offset = geometry.size.height * 0.2
                                }
                        }
                        .frame(height: geometry.size.height * 0.4)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(20)
                    
                    Spacer()
                }
                
                // Ekran altındaki kontroller:
                VStack(spacing: 10) {
                    Spacer() // Alttaki kontrol alanını sayfanın en altına atabilmek için üst tarafına alabildiğince boşluk atıyoruz.
                    
                    HStack(alignment: .bottom) {
                        VStack {
                            ResolutionView(resolution: currentResolutionName)
                                .padding(.bottom, 5)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text(formattedRecordingTime)
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Divider() // Alt çizgi:
                        .background(Color.white).opacity(0.3)
                        .padding(.bottom, 5)
                        .padding(.horizontal, 20)
                    
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
                        
                        // Kamerayı çevir:
                        ActionCircleButton(
                            iconName: "camera.rotate",
                            iconSize: 27,
                            action: {
                                isFrontCamera.toggle()
                                print("Kamera değiştiriliyor. Şu an \(isFrontCamera ? "ön" : "arka") kamera aktif.")

                                DispatchQueue.main.async {
                                    CameraManager.shared.configureSession(isFrontCamera: isFrontCamera)
                                    let preset = CameraManager.shared.session.sessionPreset.rawValue
                                    currentResolutionName = resolutionDisplayName(for: preset)
                                    print("Aktif çözünürlük: \(currentResolutionName)")
                                }
                            }
                        )

                        // Kamera:
                        ActionCircleButton(
                            iconName: isRecording ? "stop.circle" : "record.circle",
                            backgroundColor: .clear,
                            iconColor: isRecording ? .red : .green,
                            action: {
                                if isRecording {
                                    stopRecording()
                                    stopRecordingTimer()
                                } else {
                                    startRecording()
                                    startRecordingTimer()
                                }
                                isRecording.toggle()
                            }
                        )
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                }
            }
            .onAppear {
                DispatchQueue.global(qos: .userInitiated).async {
                    while !CameraManager.shared.session.isRunning { 
                        sleep(1)
                    }
                    DispatchQueue.main.async {
                        let preset = CameraManager.shared.session.sessionPreset.rawValue
                        currentResolutionName = resolutionDisplayName(for: preset)
                        print("Başlangıç çözünürlüğü: \(currentResolutionName)")
                    }
                }
            }

            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                isLandscape = UIDevice.current.orientation.isLandscape
            }
            
            .alert(isPresented: $showSaveMessage) {
                Alert(
                    title: Text("Kayıt Tamamlandı"),
                    message: Text("Video galeriye kaydedilmiştir."),
                    dismissButton: .default(Text("Tamam"))
                )
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden()
    }
    
    func startRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTime = 0
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            recordingTime += 1
        }
    }

    func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingTime = 0
    }
    
    // Kayıt başlatma
    func startRecording() {
        timer?.invalidate()
        timer = nil

        coordinator = nil
        let outputPath = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")

        let newCoordinator = Coordinator()
        newCoordinator.onSave = {
            self.showSaveMessage = true
        }
        coordinator = newCoordinator
        CameraManager.shared.startRecording(to: outputPath, delegate: newCoordinator)

        startScrollingText()
    }

    // Kayıt durdurma
    func stopRecording() {
        CameraManager.shared.stopRecording()
        timer?.invalidate()
        timer = nil
    }

    // Metni kaydırma işlemi
    func startScrollingText() {
        let safeAreaTop = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.safeAreaInsets.top ?? 0
        let textHeight = text.height(forFont: UIFont.systemFont(ofSize: CGFloat(fontSize)), width: UIScreen.main.bounds.width)
        let visibleHeight: CGFloat = UIScreen.main.bounds.height * 0.4 // Kutunun üst tarafta belirnen yüksekliği.
        let ofsetHeight: CGFloat = (textHeight + safeAreaTop + 60) - (visibleHeight / 2)

        offset = (visibleHeight + safeAreaTop - 60)  / 2 // Video kaydı başlangıcında metin, kutunun ortasından başlasın diye.

        timer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { _ in
            offset -= CGFloat(readingSpeed) // Metni yukarı kaydırma işlemi.

            // Eğer metnin tamamı yukarı doğru kaymışsa, işlemleri durdur:
            if offset < -ofsetHeight {
                timer?.invalidate()
                timer = nil
            }
        }
    }

    class Coordinator: NSObject, AVCaptureFileOutputRecordingDelegate {
        var onSave: (() -> Void)?

        func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
            if let error = error {
                print("Kayıt tamamlanamadı: \(error.localizedDescription)")
            } else {
                print("Kayıt başarıyla tamamlandı: \(outputFileURL)")
                saveVideoToGallery(outputFileURL)
                onSave?()
            }
        }

        private func saveVideoToGallery(_ fileURL: URL) {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
            }) { success, error in
                if success {
                    print("Video başarıyla galeriye kaydedildi.")
                } else if let error = error {
                    print("Video galeriye kaydedilemedi: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct ResolutionView: View {
    var resolution: String

    var body: some View {
        Image(resolutionImageName(for: resolution))
            .resizable()
            .scaledToFit()
            .frame(height: 18)
            .alignmentGuide(.leading) { _ in 0 }
    }

    func resolutionImageName(for resolution: String) -> String {
        switch resolution {
        case "4k": return "4k"
        case "1080p": return "1080p"
        case "720p": return "720p"
        case "480p": return "480p"
        default: return "defaultResolution"
        }
    }
}

struct RecordingView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingView(text: "Buraya, video kaydınız sırasında ekranda aşağı doğru kaymasını istediğiniz bir okuma metni girebilirsiniz. Gördüğünüz bu metin, bir örnek niteliği taşıyıp, dilediğiniz zaman silebilir veya değiştirebilirsiniz.", readingSpeed: 2.6, fontSize: 42)
    }
}
