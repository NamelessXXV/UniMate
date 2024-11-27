//
//  ChatView.swift
//  UniMate
//
//  Created by Sheky Cheung on 25/11/2024.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var messageTimestamps: Set<String> = []
    @State private var showProfile = false
    
    init(currentUserId: String, otherUserId: String) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(currentUserId: currentUserId, otherUserId: otherUserId))
    }
    
    var body: some View {
        ZStack {
            // Hidden NavigationLink
            NavigationLink(
                destination: ProfileView(userId: viewModel.otherUserId),
                isActive: $showProfile
            ) { EmptyView() }
            
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(groupMessagesByDate(), id: \.date) { group in
                                DateHeader(date: group.date)
                                    .padding(.vertical, 10)
                                
                                ForEach(Array(group.messages.enumerated()), id: \.element.id) { index, message in
                                    MessageBubble(
                                        message: message,
                                        isFromCurrentUser: message.senderId == viewModel.currentUserId,
                                        showTimestamp: shouldShowTimestamp(for: message, at: index, in: group.messages)
                                    )
                                    .id(message.id)
                                    .onTapGesture {
                                        withAnimation {
                                            if messageTimestamps.contains(message.id) {
                                                messageTimestamps.remove(message.id)
                                            } else {
                                                messageTimestamps.insert(message.id)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        withAnimation {
                            proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                
                HStack {
                    TextField("Message \(viewModel.otherUser?.username ?? "")...", text: $viewModel.newMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: viewModel.sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Button(action: {
                        showProfile = true
                    }) {
                        HStack(spacing: 8) {
                            // Profile Picture
                            if let photoURL = viewModel.otherUser?.photoURL, let url = URL(string: photoURL) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.gray)
                            }
                            
                            // Username
                            Text(viewModel.otherUser?.username ?? "Chat")
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.width > 100 {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
            )
        }
    }
    
    private func groupMessagesByDate() -> [(date: Date, messages: [Message])] {
        let groupedMessages = Dictionary(grouping: viewModel.messages) { message in
            Calendar.current.startOfDay(for: Date(timeIntervalSince1970: message.timestamp/1000))
        }
        return groupedMessages.map { (date: $0.key, messages: $0.value.sorted { $0.timestamp < $1.timestamp }) }
            .sorted { $0.date < $1.date }
    }
    
    private func shouldShowTimestamp(for message: Message, at index: Int, in messages: [Message]) -> Bool {
        // Show timestamp if manually selected
        if messageTimestamps.contains(message.id) {
            return true
        }
        
        // Show timestamp for the last message in the group
        if index == messages.count - 1 {
            return true
        }
        
        // Show timestamp if next message is from a different user
        if index < messages.count - 1 {
            let nextMessage = messages[index + 1]
            if message.senderId != nextMessage.senderId {
                return true
            }
        }
        
        return false
    }
}
