// ChatViewModel.swift
// Wong Kai Ching 3036067884

import Firebase
import FirebaseDatabase

// ViewModel to handle ChatView backend
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
    
    // Function for initializing new chat
    private func setupChat() {
        let chatRef = database.reference().child("chats").child(chatId)
        
        // First check if the chat already exists
        chatRef.child("participants").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            // Only create the chat if it doesn't exist
            if !snapshot.exists() {
                // First create the chat with participants
                let chatData: [String: Any] = [
                    "participants": [
                        self.currentUserId: true,
                        self.otherUserId: true
                    ]
                ]
                
                // Create chat first, then update user_chats
                chatRef.setValue(chatData) { error, _ in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.error = error.localizedDescription
                        }
                        return
                    }
                    
                    // After chat is created, update user_chats
                    let userChatsUpdates: [String: Any] = [
                        "/user_chats/\(self.currentUserId)/\(self.chatId)": true,
                        "/user_chats/\(self.otherUserId)/\(self.chatId)": true
                    ]
                    
                    self.database.reference().updateChildValues(userChatsUpdates) { error, _ in
                        if let error = error {
                            DispatchQueue.main.async {
                                self.error = error.localizedDescription
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Function to fetch the other users' information
    private func fetchOtherUser() {
        Task {
            do {
                let user = try await FirebaseService.shared.fetchUser(userId: otherUserId)
                await MainActor.run {
                    self.otherUser = user
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                }
            }
        }
    }
    
    // Function to fetch messages from Firebase RTDB
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
    
    // Function to send messages to Firebase RTDB
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
