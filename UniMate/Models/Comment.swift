// Models/Comment.swift
// Created by Wu Kwun To
// UID: 3036050726
import Foundation

struct Comment: Codable, Identifiable {
    let id: String
    let postId: String
    let authorId: String
    let content: String
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case postId
        case authorId
        case content
        case timestamp
    }
}
