// Models/User.swift
import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let username: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case username
    }
}
