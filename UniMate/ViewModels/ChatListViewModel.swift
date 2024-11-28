//
//  ChatListViewModel.swift
//  UniMate
//
//  Created by Cheung Yan Shek 3036065575 on 25/11/2024.
//

import Firebase
import FirebaseAuth
import CoreData

// ViewModel to handle all ChatListView backend functions
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
        observeNewChats()
    }
    
    func setupAutoRefresh() {
        autoRefreshTimer?.invalidate()
        
        // 5 seconds timer
        autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            print("🔄 Chat refreshed")  // for debug
            self?.loadChats()
        }
    }
    
    private func observeNewChats() {
        let userChatsRef = database.reference().child("user_chats").child(currentUserId)
        userChatsRef.observe(.childAdded) { [weak self] snapshot in
            guard let self = self,
                  !self.chatPreviews.contains(where: { $0.id == snapshot.key }) else { return }
            
            self.loadChats()
        }
    }
    
    // Function to load cached chats from CoreData
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
    
    // Function to cache chats to CoreData
    private func updateCoreData(with newPreviews: [ChatPreview]) {
        let context = coreDataManager.viewContext
        
        coreDataManager.clearAllChatPreviews()
        
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
    
    // Major function to load chats from Firebase RTDB
    func loadChats() {
        guard !currentUserId.isEmpty else {
            self.error = "No authenticated user"
            print("Debug: No authenticated user")
            return
        }
        
        let userChatsRef = database.reference().child("user_chats").child(currentUserId)
        
        if let handle = userChatsHandle {
            userChatsRef.removeObserver(withHandle: handle)
        }
        
        userChatsHandle = userChatsRef.observe(.value) { [weak self] snapshot in
            
            guard let self = self else { return }
            
            guard let chatDict = snapshot.value as? [String: Any] else {
                print("Debug: No chats found or invalid format")
                DispatchQueue.main.async {
                    self.chatPreviews = []
                    self.updateCoreData(with: [])
                }
                return
            }
            
            // Create an async Task to handle all chat previews
            Task {
                var newPreviews: [ChatPreview] = []
                
                for (chatId, _) in chatDict {
                    
                    do {
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
