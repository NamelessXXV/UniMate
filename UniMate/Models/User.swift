// Models/User.swift
// Created by Wu Kwun To
// UID: 3036050726
import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let username: String
    let fullName: String?
    let photoURL: String?
    let bio: String?
    let tags: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case username
        case fullName
        case photoURL
        case bio
        case tags
    }
}
