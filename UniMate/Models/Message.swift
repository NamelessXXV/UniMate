//
//  Message.swift
//  UniMate
//
//  Created by Sheky Cheung on 25/11/2024.
//

import Foundation

struct Message: Codable, Identifiable {
    let id: String
    let senderId: String
    let receiverId: String
    let content: String
    let timestamp: TimeInterval
    let isRead: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case senderId
        case receiverId
        case content
        case timestamp
        case isRead
    }
}
