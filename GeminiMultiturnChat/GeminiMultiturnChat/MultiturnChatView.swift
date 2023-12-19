//
//  MultiturnChatView.swift
//  GeminiMultiturnChat
//
//  Created by Anup D'Souza
//
import SwiftUI

struct MultiturnChatView: View {
    @State var textInput = ""
    @State var logoAnimating = false
    @State var timer: Timer?
    @State var chatService = ChatService()
    
    
    
    var body: some View {
        ZStack (alignment : .top) {
            // MARK: Animating logo
            Image(.geminiLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .opacity(logoAnimating ? 0.5 : 1)
                .animation(.easeInOut, value: logoAnimating)
            
            VStack {
                
                
                // MARK: Chat message list
                ScrollViewReader(content: { proxy in
                    ScrollView {
                        ForEach(chatService.messages) { chatMessage in
                            // MARK: Chat message view
                            chatMessageView(chatMessage)
                        }
                    }
                    .onChange(of: chatService.messages) { _, _ in
                        guard let recentMessage = chatService.messages.last else { return }
                        DispatchQueue.main.async {
                            withAnimation {
                                proxy.scrollTo(recentMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: chatService.loadingResponse) { _, newValue in
                        if newValue {
                            startLoadingAnimation()
                        } else {
                            stopLoadingAnimation()
                        }
                    }
                })
                
                // MARK: Input fields
                HStack {
                    TextEditor(text: $textInput)
                        .frame(height: max(20, CGFloat(lineCount() * 20)))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                        .padding()

                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.blue)
                            .padding(8) // ボタン内の余白を調整
                            .cornerRadius(8)
                            .shadow(color: .gray, radius: 2, x: 1, y: 1) // 影を追加
                    }
                    .padding(.leading) // 左側の余白を追加
                }
            }
        }
        .foregroundStyle(.white)
        .padding()
        .background {
            // MARK: Background
            ZStack {
                Color.primary
            }
            .ignoresSafeArea()
        }
    }
    
    // MARK: Chat message view
    @ViewBuilder func chatMessageView(_ message: ChatMessage) -> some View {
        ChatBubble(direction: message.role == .model ? .left : .right) {
            Text(message.message)
                .font(.title3)
                .padding(.all, 20)
                .foregroundStyle(.white)
                .background(message.role == .model ? Color.blue : Color.green)
        }
    }
    
    // MARK: Fetch response
    func sendMessage() {
        chatService.sendMessage(textInput)
        textInput = ""
    }
    // MARK: Response loading animation
    func startLoadingAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { timer in
            logoAnimating.toggle()
        })
    }
    
    func stopLoadingAnimation() {
        logoAnimating = false
        timer?.invalidate()
        timer = nil
    }
    
    func lineCount() -> Int {
        let lineBreaks = textInput.components(separatedBy: CharacterSet.newlines)
        return lineBreaks.count
    }
}

#Preview {
    MultiturnChatView()
}
