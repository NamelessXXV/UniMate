//
//  MessageBubble.swift
//  UniMate
//
//  Created by Sheky Cheung on 25/11/2024.
//

import SwiftUI

struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer() }
            
            Text(message.content)
                .padding(10)
                .background(isFromCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isFromCurrentUser ? .white : .primary)
                .cornerRadius(10)
            
            if !isFromCurrentUser { Spacer() }
        }
    }
}

struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MessageBubble(message: Message(
                id: "1",
                senderId: "user1",
                receiverId: "user2",
                content: "Hello!",
                timestamp: Date().timeIntervalSince1970,
                isRead: false
            ), isFromCurrentUser: true)
            
            MessageBubble(message: Message(
                id: "2",
                senderId: "user2",
                receiverId: "user1",
                content: "Hi there!",
                timestamp: Date().timeIntervalSince1970,
                isRead: false
            ), isFromCurrentUser: false)
        }
        .padding()
    }
}
