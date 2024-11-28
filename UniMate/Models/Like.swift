// Models/Like.swift
// Created by Wu Kwun To
// UID: 3036050726
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
