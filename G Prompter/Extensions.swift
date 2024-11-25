import UIKit
import SwiftUI
import AVFoundation

extension String {
    func height(forFont font: UIFont, width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

extension UIColor {
    convenience init?(hex: String) {
        let r, g, b: CGFloat

        guard hex.hasPrefix("#") else { return nil }
        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])

        guard hexColor.count == 6 else { return nil }
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0

        guard scanner.scanHexInt64(&hexNumber) else { return nil }

        r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
        g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
        b = CGFloat(hexNumber & 0x0000FF) / 255

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

func topSafeAreaPadding() -> CGFloat {
    UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }?.safeAreaInsets.top ?? 0
}

struct ActionCircleButton: View {
    let iconName: String
    var iconSize: CGFloat = 25
    var backgroundColor: Color = .white
    var iconColor: Color = Color(hex: "#32CD32")
    var action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            ZStack {
                if backgroundColor != .clear {
                    Circle() // Arka plan
                        .fill(backgroundColor)
                        .frame(width: 50, height: 50)
                }
                
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(iconColor)
                    .frame(width: backgroundColor == .clear ? 50 : iconSize, // Şeffafsa 50, değilse 24
                           height: backgroundColor == .clear ? 50 : iconSize)
            }
        }
    }
}

struct NavigationCircleButton<Destination: View>: View {
    let iconName: String
    var iconSize: CGFloat = 25
    var backgroundColor: Color = .white
    var iconColor: Color = Color(hex: "#32CD32")
    var destination: () -> Destination

    var body: some View {
        NavigationLink(destination: LazyView(destination)) {
            Image(systemName: iconName)
                .font(.system(size: iconSize))
                .foregroundColor(iconColor)
                .frame(width: 50, height: 50)
                .background(backgroundColor)
                .clipShape(Circle())
        }
    }
}

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

func resolutionDisplayName(for preset: String) -> String {
    switch preset {
    case AVCaptureSession.Preset.hd4K3840x2160.rawValue:
        return "4k"
    case AVCaptureSession.Preset.hd1920x1080.rawValue:
        return "1080p"
    case AVCaptureSession.Preset.hd1280x720.rawValue:
        return "720p"
    case AVCaptureSession.Preset.vga640x480.rawValue:
        return "480p"
    default:
        return "Unknown"
    }
}
