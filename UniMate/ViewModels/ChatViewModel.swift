//
//  ChatViewModel.swift
//  UniMate
//
//  Created by Sheky Cheung on 25/11/2024.
//
import Firebase
import FirebaseDatabase


class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var newMessage: String = ""
    @Published var otherUser: User?
    @Published var error: String? = nil
    
    private let database = Database.database(url: "https://unimate-demo-default-rtdb.asia-southeast1.firebasedatabase.app")
    private var messagesRef: DatabaseReference?
    private var messagesHandle: DatabaseHandle?
    
    let currentUserId: String
    let otherUserId: String
    private let chatId: String
    
    init(currentUserId: String, otherUserId: String) {
        self.currentUserId = currentUserId
        self.otherUserId = otherUserId
        self.chatId = [currentUserId, otherUserId].sorted().joined(separator: "_")
        self.messagesRef = database.reference().child("chats").child(chatId).child("messages")
        
        setupChat()
        fetchOtherUser()
        observeMessages()
    }
    
    private func setupChat() {
        let participantsRef = database.reference().child("chats").child(chatId).child("participants")
        participantsRef.updateChildValues([
            currentUserId: true,
            otherUserId: true
        ]) { [weak self] error, _ in
            if let error = error {
                DispatchQueue.main.async {
                    self?.error = error.localizedDescription
                }
                return
            }
            
            // Add to user_chats for both users
            let userChatsRef = self?.database.reference().child("user_chats")
            userChatsRef?.child(self?.currentUserId ?? "").updateChildValues([self?.chatId ?? "": true])
            userChatsRef?.child(self?.otherUserId ?? "").updateChildValues([self?.chatId ?? "": true])
        }
    }
    
    private func fetchOtherUser() {
        database.reference().child("users").child(otherUserId).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let userData = snapshot.value as? [String: Any] else { return }
            
            do {
                var userDict = userData
                userDict["id"] = self?.otherUserId // Add id to the dictionary before decoding
                let jsonData = try JSONSerialization.data(withJSONObject: userDict)
                let user = try JSONDecoder().decode(User.self, from: jsonData)
                
                DispatchQueue.main.async {
                    self?.otherUser = user
                }
            } catch {
                DispatchQueue.main.async {
                    self?.error = "Failed to decode user data: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func observeMessages() {
        messagesHandle = messagesRef?.observe(.childAdded) { [weak self] snapshot in
            guard let messageData = snapshot.value as? [String: Any] else { return }
            
            let message = Message(
                id: snapshot.key,
                senderId: messageData["senderId"] as? String ?? "",
                receiverId: messageData["receiverId"] as? String ?? "",
                content: messageData["content"] as? String ?? "",
                timestamp: messageData["timestamp"] as? TimeInterval ?? 0,
                isRead: messageData["isRead"] as? Bool ?? false
            )
            
            DispatchQueue.main.async {
                self?.messages.append(message)
                self?.messages.sort { $0.timestamp < $1.timestamp }
                
                // Mark message as read if received by current user
                if message.receiverId == self?.currentUserId && !message.isRead {
                    self?.markMessageAsRead(messageId: message.id)
                }
            }
        }
    }
    
    private func markMessageAsRead(messageId: String) {
        messagesRef?.child(messageId).updateChildValues(["isRead": true])
    }
    
    func sendMessage() {
        guard !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let messageData: [String: Any] = [
            "senderId": currentUserId,
            "receiverId": otherUserId,
            "content": newMessage,
            "timestamp": ServerValue.timestamp(),
            "isRead": false
        ]
        
        messagesRef?.childByAutoId().setValue(messageData) { [weak self] error, _ in
            if let error = error {
                DispatchQueue.main.async {
                    self?.error = error.localizedDescription
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.newMessage = ""
            }
        }
    }
    
    deinit {
        if let handle = messagesHandle {
            messagesRef?.removeObserver(withHandle: handle)
        }
    }
}
