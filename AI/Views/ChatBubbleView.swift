import SwiftUI
import Models

public struct ChatBubbleView: View {
    let message: ChatMessage
    
    public init(message: ChatMessage) {
        self.message = message
    }
    
    public var body: some View {
        HStack {
            if message.role == "user" { Spacer() }
            
            Text(message.content)
                .font(.system(size: 15))
                .padding(12)
                .background(
                    message.role == "user" ? Color(hex: "#0A84FF") : Color(hex: "#1C1C1E")
                )
                .foregroundColor(.white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(message.role == "user" ? 0.0 : 0.1), lineWidth: 1)
                )
                .frame(maxWidth: 280, alignment: message.role == "user" ? .trailing : .leading)
            
            if message.role != "user" { Spacer() }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}
