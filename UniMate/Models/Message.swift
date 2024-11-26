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
    
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create dictionary"])
        }
        return dictionary
    }
}
