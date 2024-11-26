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
    let showTimestamp: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer() }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading) {
                Text(message.content)
                    .padding(10)
                    .background(isFromCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(isFromCurrentUser ? .white : .black)
                    .cornerRadius(16)
                
                if showTimestamp {
                    Text(formatMessageTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 4)
                }
            }
            
            if !isFromCurrentUser { Spacer() }
        }
    }
    
    private func formatMessageTime(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp/1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
