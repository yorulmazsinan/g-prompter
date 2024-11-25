import SwiftUI

struct CustomTextEditor: UIViewRepresentable {
    @Binding var text: String
    var font: UIFont
    var textColor: UIColor
    var alignment: NSTextAlignment
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // Kenar boşlukları
        textView.font = font
        textView.textColor = textColor
        textView.textAlignment = alignment
        textView.isScrollEnabled = true
        textView.isEditable = true
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.font = font
        uiView.textColor = textColor
        uiView.textAlignment = alignment
    }
}
