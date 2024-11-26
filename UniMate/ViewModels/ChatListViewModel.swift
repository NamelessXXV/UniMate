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
        loadChats()
    }
    
    func loadChats() {
        guard !currentUserId.isEmpty else {
            self.error = "No authenticated user"
            return
        }
        
        let userChatsRef = database.reference().child("user_chats").child(currentUserId)
        
        userChatsHandle = userChatsRef.observe(.value) { [weak self] snapshot in
            guard let self = self,
                  let chatDict = snapshot.value as? [String: Any] else {
                DispatchQueue.main.async {
                    self?.chatPreviews = []
                }
                return
            }
            
            let dispatchGroup = DispatchGroup()
            var newPreviews: [ChatPreview] = []
            
            for (chatId, _) in chatDict {
                dispatchGroup.enter()
                self.fetchChatPreview(chatId: chatId) { preview in
                    if let preview = preview {
                        newPreviews.append(preview)
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.chatPreviews = newPreviews.sorted { ($0.timestamp ?? 0) > ($1.timestamp ?? 0) }
            }
        }
    }
    
    private func fetchChatPreview(chatId: String, completion: @escaping (ChatPreview?) -> Void) {
        let chatRef = database.reference().child("chats").child(chatId)
        
        chatRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self,
                  let chatData = snapshot.value as? [String: Any],
                  let participants = chatData["participants"] as? [String: Bool] else {
                completion(nil)
                return
            }
            
            let otherUserId = participants.keys.first { $0 != self.currentUserId } ?? ""
            
            database.reference().child("users").child(otherUserId).observeSingleEvent(of: .value) { snapshot in
                guard let userData = snapshot.value as? [String: Any] else {
                    completion(nil)
                    return
                }
                
                do {
                    var userDict = userData
                    userDict["id"] = otherUserId // Add id to the dictionary before decoding
                    let jsonData = try JSONSerialization.data(withJSONObject: userDict)
                    let user = try JSONDecoder().decode(User.self, from: jsonData)
                    
                    let messages = chatData["messages"] as? [String: Any] ?? [:]
                    let sortedMessages = messages.values
                        .compactMap { $0 as? [String: Any] }
                        .sorted { ($0["timestamp"] as? TimeInterval ?? 0) > ($1["timestamp"] as? TimeInterval ?? 0) }
                    
                    let lastMessage = sortedMessages.first
                    let unreadCount = sortedMessages
                        .filter { ($0["receiverId"] as? String == self.currentUserId) &&
                                ($0["isRead"] as? Bool == false) }
                        .count
                    
                    let preview = ChatPreview(
                        id: chatId,
                        otherUserId: otherUserId,
                        username: user.username,
                        lastMessage: lastMessage?["content"] as? String ?? "No messages",
                        timestamp: lastMessage?["timestamp"] as? TimeInterval,
                        unreadCount: unreadCount
                    )
                    
                    completion(preview)
                } catch {
                    DispatchQueue.main.async {
                        self.error = "Failed to decode user data: \(error.localizedDescription)"
                    }
                    completion(nil)
                }
            }
        }
    }
    
    deinit {
        if let handle = userChatsHandle {
            database.reference().child("user_chats").child(currentUserId).removeObserver(withHandle: handle)
        }
    }
}
