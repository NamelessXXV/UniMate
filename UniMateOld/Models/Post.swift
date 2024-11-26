// Models/Post.swift
import Foundation

struct Post: Codable, Identifiable {
    let id: String
    let authorId: String
    let title: String
    let content: String
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorId
        case title
        case content
        case timestamp
    }
}
