//
//  ChatListViewModel.swift
//  UniMate
//
//  Created by Sheky Cheung on 25/11/2024.
//

import Firebase
import FirebaseAuth
import CoreData

class ChatListViewModel: ObservableObject {
    @Published var chatPreviews: [ChatPreview] = []
    @Published var error: String? = nil
    private var autoRefreshTimer: Timer?
    
    let currentUserId: String
    private let database = Database.database(url: "https://unimate-demo-default-rtdb.asia-southeast1.firebasedatabase.app")
    private var userChatsHandle: DatabaseHandle?
    private let coreDataManager = CoreDataManager.shared
    
    init() {
        self.currentUserId = Auth.auth().currentUser?.uid ?? ""
        print("Debug: Initialized ChatListViewModel with currentUserId: \(currentUserId)")
        loadCachedChats()
        loadChats()
        setupAutoRefresh()
    }
    
    func setupAutoRefresh() {
        // Invalidate existing timer if any
        autoRefreshTimer?.invalidate()
        
        // Create new timer that fires every 3 seconds
        autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            print("🔄 Chat refreshed")
            self?.loadChats()
        }
    }
    
    private func loadCachedChats() {
        let fetchRequest: NSFetchRequest<ChatPreviewEntity> = ChatPreviewEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ChatPreviewEntity.timestamp, ascending: false)]
        
        do {
            let entities = try coreDataManager.viewContext.fetch(fetchRequest)
            let previews = entities.map { entity in
                ChatPreview(
                    id: entity.id ?? "",
                    otherUserId: entity.otherUserId ?? "",
                    otherUserPhotoURL: entity.otherUserPhotoURL ?? "",
                    username: entity.username ?? "",
                    lastMessage: entity.lastMessage ?? "",
                    timestamp: entity.timestamp,
                    unreadCount: Int(entity.unreadCount)
                )
            }
            DispatchQueue.main.async {
                self.chatPreviews = previews
            }
        } catch {
            print("Debug: Error fetching cached chats: \(error)")
        }
    }
    
    private func updateCoreData(with newPreviews: [ChatPreview]) {
        let context = coreDataManager.viewContext
        
        // Clear existing data
        coreDataManager.clearAllChatPreviews()
        
        // Insert new data
        for preview in newPreviews {
            let entity = ChatPreviewEntity(context: context)
            entity.id = preview.id
            entity.otherUserId = preview.otherUserId
            entity.otherUserPhotoURL = preview.otherUserPhotoURL
            entity.username = preview.username
            entity.lastMessage = preview.lastMessage
            entity.timestamp = preview.timestamp ?? 0
            entity.unreadCount = Int32(preview.unreadCount)
        }
        
        coreDataManager.saveContext()
    }
    
    func loadChats() {
        guard !currentUserId.isEmpty else {
            self.error = "No authenticated user"
            print("Debug: No authenticated user")
            return
        }
        
//        print("Debug: Loading chats for user: \(currentUserId)")
        let userChatsRef = database.reference().child("user_chats").child(currentUserId)
        
        if let handle = userChatsHandle {
            userChatsRef.removeObserver(withHandle: handle)
        }
        
        userChatsHandle = userChatsRef.observe(.value) { [weak self] snapshot in
//            print("Debug: Received snapshot: \(snapshot.value ?? "nil")")
            
            guard let self = self else { return }
            
            guard let chatDict = snapshot.value as? [String: Any] else {
                print("Debug: No chats found or invalid format")
                DispatchQueue.main.async {
                    self.chatPreviews = []
                    self.updateCoreData(with: [])
                }
                return
            }
            
//            print("Debug: Found \(chatDict.count) chats")
            
            // Create an async Task to handle all chat previews
            Task {
                var newPreviews: [ChatPreview] = []
                
                // Use async/await instead of DispatchGroup
                for (chatId, _) in chatDict {
//                    print("Debug: Fetching preview for chat: \(chatId)")
                    
                    do {
                        // Convert Firebase callback to async/await
                        let chatData = try await withCheckedThrowingContinuation { continuation in
                            let chatRef = self.database.reference().child("chats").child(chatId)
                            chatRef.observeSingleEvent(of: .value) { snapshot in
                                if let chatData = snapshot.value as? [String: Any] {
                                    continuation.resume(returning: chatData)
                                } else {
                                    continuation.resume(throwing: NSError(domain: "", code: -1))
                                }
                            }
                        }
                        
                        guard let participants = chatData["participants"] as? [String: Bool] else { continue }
                        
                        let otherUserId = participants.keys.first { $0 != self.currentUserId } ?? ""
//                        print("Debug: Other user ID: \(otherUserId)")
                        
                        let otherUserPhotoURL = try await FirebaseService.shared.fetchUser(userId: otherUserId).photoURL
                        let messages = chatData["messages"] as? [String: Any] ?? [:]
                        let sortedMessages = messages.values
                            .compactMap { $0 as? [String: Any] }
                            .sorted { ($0["timestamp"] as? TimeInterval ?? 0) > ($1["timestamp"] as? TimeInterval ?? 0) }
                        
                        let lastMessage = sortedMessages.first
                        let unreadCount = sortedMessages
                            .filter { ($0["receiverId"] as? String == self.currentUserId) &&
                                ($0["isRead"] as? Bool == false) }
                            .count
                        
                        do {
                            let user = try await FirebaseService.shared.fetchUser(userId: otherUserId)
                            let preview = ChatPreview(
                                id: chatId,
                                otherUserId: otherUserId,
                                otherUserPhotoURL: otherUserPhotoURL,
                                username: user.username,
                                lastMessage: lastMessage?["content"] as? String ?? "No messages",
                                timestamp: lastMessage?["timestamp"] as? TimeInterval,
                                unreadCount: unreadCount
                            )
                            newPreviews.append(preview)
                        } catch {
                            print("Debug: Error fetching user \(otherUserId): \(error)")
                            let preview = ChatPreview(
                                id: chatId,
                                otherUserId: otherUserId,
                                otherUserPhotoURL: otherUserPhotoURL,
                                username: "User \(otherUserId.prefix(6))",
                                lastMessage: lastMessage?["content"] as? String ?? "No messages",
                                timestamp: lastMessage?["timestamp"] as? TimeInterval,
                                unreadCount: unreadCount
                            )
                            newPreviews.append(preview)
                        }
                    } catch {
                        print("Debug: Error fetching chat data: \(error)")
                    }
                }
                
                // Update UI on main thread after all chats are processed
                await MainActor.run {
//                    print("Debug: Updating chat previews, count: \(newPreviews.count)")
                    let sortedPreviews = newPreviews.sorted { ($0.timestamp ?? 0) > ($1.timestamp ?? 0) }
                    self.updateCoreData(with: sortedPreviews)
                    self.chatPreviews = sortedPreviews
                }
            }
        }
    }
    
    deinit {
        if let handle = userChatsHandle {
            database.reference().child("user_chats").child(currentUserId).removeObserver(withHandle: handle)
        }
        autoRefreshTimer?.invalidate()
    }
}
