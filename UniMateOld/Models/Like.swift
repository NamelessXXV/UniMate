// Models/Like.swift
import Foundation

struct Like: Codable, Identifiable {
    let id: String
    let postId: String
    let userId: String
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case postId
        case userId
        case timestamp
    }
}
