// Created by Wu Kwun To
// UID: 3036050726
import Foundation
import FirebaseFirestore

struct Post: Identifiable, Codable {
    @DocumentID var id: String?
    let authorId: String
    var title: String
    var content: String
    let timestamp: Date
    let category: String
    
    var postCategory: PostCategory {
        PostCategory(rawValue: category) ?? .general
    }

    
    init(id: String? = nil, authorId: String, title: String, content: String, timestamp: Date, category: String) {
        self.id = id
        self.authorId = authorId
        self.title = title
        self.content = content
        self.timestamp = timestamp
        self.category = category
    }
}
