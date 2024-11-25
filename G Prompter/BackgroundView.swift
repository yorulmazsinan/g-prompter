import SwiftUI

struct BackgroundView: View {
    var body: some View {
        GeometryReader { geometry in
            Image("backgroundImage")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(Color.black.opacity(0.8))
                .frame(maxWidth: geometry.size.width, maxHeight:geometry.safeAreaInsets.top + geometry.size.height + geometry.safeAreaInsets.bottom, alignment: .topLeading)
                .clipped()
        }
    }
}
