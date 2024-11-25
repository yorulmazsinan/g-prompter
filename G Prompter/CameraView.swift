import SwiftUI
import AVFoundation
import UIKit

struct CameraView: UIViewRepresentable {
    @Binding var isFrontCamera: Bool

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        DispatchQueue.global(qos: .background).async {
            if !CameraManager.shared.isConfigured {
                CameraManager.shared.configureSession(isFrontCamera: isFrontCamera)
            }
            
            // Arka planda oturumu başlat:
            if !CameraManager.shared.session.isRunning {
                CameraManager.shared.session.startRunning()
            }
            
            // Ana thread üzerinde önizleme katmanını ekle:
            DispatchQueue.main.async {
                setupPreviewLayer(for: view)
            }
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        
    }

    private func setupPreviewLayer(for view: UIView) {
        // Mevcut önizleme katmanlarını temizle:
        view.layer.sublayers?.forEach { layer in
            if layer is AVCaptureVideoPreviewLayer {
                layer.removeFromSuperlayer()
            }
        }

        // Yeni önizleme katmanını ekle:
        let previewLayer = AVCaptureVideoPreviewLayer(session: CameraManager.shared.session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        previewLayer.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        
        view.layer.addSublayer(previewLayer)
    }
}
