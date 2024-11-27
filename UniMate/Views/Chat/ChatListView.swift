//
//  ChatListView.swift
//  UniMate
//
//  Created by Sheky Cheung on 25/11/2024.
//

import SwiftUI
import Firebase

struct ChatListView: View {
    @StateObject private var viewModel = ChatListViewModel()
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.chatPreviews.isEmpty {
                    VStack(spacing: 16) {
                        Text("No chats yet")
                            .font(.headline)
                        if let error = viewModel.error {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    }
                } else {
                    List(viewModel.chatPreviews) { preview in
                        NavigationLink(destination: ChatView(currentUserId: viewModel.currentUserId, otherUserId: preview.otherUserId)) {
                            ChatPreviewRow(preview: preview)
                        }
                    }
                }
            }
            .navigationTitle("Chats")
            .refreshable {
                viewModel.loadChats()
            }
            .onAppear {
                viewModel.loadChats()
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    viewModel.setupAutoRefresh()
                }
            }
        }
    }
}

struct ChatPreviewRow: View {
    let preview: ChatPreview
    
    var body: some View {
        HStack {
            // You can add user avatar here if you have one
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(preview.username)
                    .font(.headline)
                Text(preview.lastMessage)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if let timestamp = preview.timestamp {
                Text(formatTimestamp(timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatTimestamp(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp/1000) // Convert milliseconds to seconds
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.dateComponents([.day], from: date, to: now).day! < 7 {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yy"
            return formatter.string(from: date)
        }
    }
}

struct ChatPreview: Identifiable {
    let id: String
    let otherUserId: String
    let username: String
    let lastMessage: String
    let timestamp: TimeInterval?
    let unreadCount: Int
}
