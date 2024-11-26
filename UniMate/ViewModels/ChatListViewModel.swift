//
//  ChatListViewModel.swift
//  UniMate
//
//  Created by Sheky Cheung on 25/11/2024.
//

import Firebase
import FirebaseAuth

class ChatListViewModel: ObservableObject {
    @Published var chatPreviews: [ChatPreview] = []
    @Published var error: String? = nil
    
    let currentUserId: String
    private let database = Database.database(url: "https://unimate-demo-default-rtdb.asia-southeast1.firebasedatabase.app")
    private var userChatsHandle: DatabaseHandle?
    
    init() {
        self.currentUserId = Auth.auth().currentUser?.uid ?? ""
        print("Debug: Initialized ChatListViewModel with currentUserId: \(currentUserId)")
        loadChats()
    }
    
    func loadChats() {
        guard !currentUserId.isEmpty else {
            self.error = "No authenticated user"
            print("Debug: No authenticated user")
            return
        }
        
        print("Debug: Loading chats for user: \(currentUserId)")
        let userChatsRef = database.reference().child("user_chats").child(currentUserId)
        
        if let handle = userChatsHandle {
            userChatsRef.removeObserver(withHandle: handle)
        }
        
        userChatsHandle = userChatsRef.observe(.value) { [weak self] snapshot in
            print("Debug: Received snapshot: \(snapshot.value ?? "nil")")
            
            guard let self = self else { return }
            
            guard let chatDict = snapshot.value as? [String: Any] else {
                print("Debug: No chats found or invalid format")
                DispatchQueue.main.async {
                    self.chatPreviews = []
                }
                return
            }
            
            print("Debug: Found \(chatDict.count) chats")
            
            let dispatchGroup = DispatchGroup()
            var newPreviews: [ChatPreview] = []
            
            for (chatId, _) in chatDict {
                dispatchGroup.enter()
                print("Debug: Fetching preview for chat: \(chatId)")
                
                let chatRef = self.database.reference().child("chats").child(chatId)
                chatRef.observeSingleEvent(of: .value) { snapshot in
                    print("Debug: Chat data for \(chatId): \(snapshot.value ?? "nil")")
                    
                    guard let chatData = snapshot.value as? [String: Any],
                          let participants = chatData["participants"] as? [String: Bool] else {
                        print("Debug: Invalid chat data format for \(chatId)")
                        dispatchGroup.leave()
                        return
                    }
                    
                    let otherUserId = participants.keys.first { $0 != self.currentUserId } ?? ""
                    print("Debug: Other user ID: \(otherUserId)")
                    
                    let messages = chatData["messages"] as? [String: Any] ?? [:]
                    let sortedMessages = messages.values
                        .compactMap { $0 as? [String: Any] }
                        .sorted { ($0["timestamp"] as? TimeInterval ?? 0) > ($1["timestamp"] as? TimeInterval ?? 0) }
                    
                    let lastMessage = sortedMessages.first
                    let unreadCount = sortedMessages
                        .filter { ($0["receiverId"] as? String == self.currentUserId) &&
                            ($0["isRead"] as? Bool == false) }
                        .count
                    
                    // Use FirebaseService to fetch user
                    Task {
                        do {
                            let user = try await FirebaseService.shared.fetchUser(userId: otherUserId)
                            let preview = ChatPreview(
                                id: chatId,
                                otherUserId: otherUserId,
                                username: user.username,
                                lastMessage: lastMessage?["content"] as? String ?? "No messages",
                                timestamp: lastMessage?["timestamp"] as? TimeInterval,
                                unreadCount: unreadCount
                            )
                            newPreviews.append(preview)
                            print("Debug: Created preview for chat \(chatId): \(preview)")
                        } catch {
                            print("Debug: Error fetching user \(otherUserId): \(error)")
                            // Create preview with user ID as fallback
                            let preview = ChatPreview(
                                id: chatId,
                                otherUserId: otherUserId,
                                username: "User \(otherUserId.prefix(6))",
                                lastMessage: lastMessage?["content"] as? String ?? "No messages",
                                timestamp: lastMessage?["timestamp"] as? TimeInterval,
                                unreadCount: unreadCount
                            )
                            newPreviews.append(preview)
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                print("Debug: Updating chat previews, count: \(newPreviews.count)")
                self.chatPreviews = newPreviews.sorted { ($0.timestamp ?? 0) > ($1.timestamp ?? 0) }
            }
        }
    }
    
    deinit {
        if let handle = userChatsHandle {
            database.reference().child("user_chats").child(currentUserId).removeObserver(withHandle: handle)
        }
    }
}
