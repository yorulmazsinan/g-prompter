import AVFoundation
import UIKit

class CameraManager {
    static let shared = CameraManager()

    let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    private var currentVideoInput: AVCaptureDeviceInput?
    private var currentAudioInput: AVCaptureDeviceInput?
    
    private var isConfiguredPrivate = false

    // Public getter
    var isConfigured: Bool {
        return isConfiguredPrivate
    }
    
    private init() {}

    func configureSession(isFrontCamera: Bool) {
        session.beginConfiguration()
        
        defer {
            session.commitConfiguration()
            isConfiguredPrivate = true
            print("Oturum başarıyla yapılandırıldı.")
            
            // Oturum ayarlandıktan sonra çalıştır
            DispatchQueue.global(qos: .userInitiated).async {
                if !self.session.isRunning {
                    self.session.startRunning()
                    print("Oturum başlatıldı.")
                }
            }
        }
        
        // Eğer kamera pozisyonu değişmediyse girişleri yeniden eklemeyin
        if let currentVideoInput = currentVideoInput,
           currentVideoInput.device.position == (isFrontCamera ? .front : .back) {
            print("Kamera zaten doğru yapılandırıldı, girişler değiştirilmiyor.")
        } else {
            // Eski girişleri temizle
            if let videoInput = currentVideoInput {
                session.removeInput(videoInput)
                currentVideoInput = nil
                print("Video girişi temizlendi.")
            }
            
            // Kamera pozisyonunu belirle
            let cameraPosition: AVCaptureDevice.Position = isFrontCamera ? .front : .back
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition) else {
                print("Seçilen kamera bulunamadı: \(cameraPosition == .front ? "ön" : "arka")")
                return
            }
            
            // Çözünürlük kontrolü
            if let bestPreset = selectBestSessionPreset(for: videoDevice) {
                if session.canSetSessionPreset(bestPreset) {
                    session.sessionPreset = bestPreset
                    print("Kullanılan çözünürlük: \(bestPreset.rawValue)")
                } else {
                    print("Seçilen preset desteklenmiyor: \(bestPreset.rawValue)")
                }
            } else {
                print("Cihaz için uygun çözünürlük bulunamadı. Varsayılan kullanılacak.")
                session.sessionPreset = .vga640x480
            }

            do {
                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                if session.canAddInput(videoInput) {
                    session.addInput(videoInput)
                    currentVideoInput = videoInput
                    print("Kamera girişi eklendi.")
                }
            } catch {
                print("Kamera giriş hatası: \(error.localizedDescription)")
                return
            }
        }

        // Mikrofonu her zaman yeniden ekle:
        if let audioDevice = AVCaptureDevice.default(for: .audio) {
            if let audioInput = currentAudioInput {
                session.removeInput(audioInput)
                currentAudioInput = nil
                print("Mikrofon girişi temizlendi.")
            }

            do {
                let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                if session.canAddInput(audioInput) {
                    session.addInput(audioInput)
                    currentAudioInput = audioInput
                    print("Mikrofon girişi eklendi.")
                }
            } catch {
                print("Mikrofon giriş hatası: \(error.localizedDescription)")
            }
        }

        // Video çıkışı eklenmemişse yeniden ekle:
        if !session.outputs.contains(movieOutput) {
            if session.canAddOutput(movieOutput) {
                session.addOutput(movieOutput)
                print("Video çıkışı eklendi.")
            }
        }
        
        // Ayna görüntüsü ayarı:
        if let connection = movieOutput.connection(with: .video), isFrontCamera {
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = true
            }
        }
    }
    
    func resetSessionConfiguration() {
        isConfiguredPrivate = false
    }
    
    private func selectBestSessionPreset(for device: AVCaptureDevice) -> AVCaptureSession.Preset? {
        // Öncelik sırasına göre çözünürlükleri kontrol ediyoruz:
        let preferredPresets: [AVCaptureSession.Preset] = [
            .hd4K3840x2160, // 4K çözünürlük
            .hd1920x1080,   // 1080p çözünürlük
            .hd1280x720,    // 720p çözünürlük
            .vga640x480     // 480p çözünürlük
        ]

        // Hangi preset destekleniyor, bunu buluyoruz
        for preset in preferredPresets {
            if device.supportsSessionPreset(preset) {
                print("Desteklenen çözünürlük bulundu: \(preset.rawValue)")
                return preset
            }
        }

        // Hiçbiri desteklenmezse, nil döner
        print("Bu cihazda hiçbir çözünürlük desteklenmiyor!")
        return nil
    }


    func startRecording(to url: URL, delegate: AVCaptureFileOutputRecordingDelegate) {
        guard !movieOutput.isRecording else {
            print("Zaten kayıt yapılıyor.")
            return
        }
        print("Kayıt başlatılıyor: \(url)")
        movieOutput.startRecording(to: url, recordingDelegate: delegate)
    }

    func stopRecording() {
        guard movieOutput.isRecording else {
            print("Kayıt yapılmıyor.")
            return
        }
        movieOutput.stopRecording()
        print("Kayıt durduruldu.")
    }
}
