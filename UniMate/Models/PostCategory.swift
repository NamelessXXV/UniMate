
// Models/PostCategory.swift
import Foundation

enum PostCategory: String, Codable, CaseIterable, Identifiable {
    case all = "All"
    case general = "General"
    case academic = "Academic"
    case social = "Social"
    case housing = "Housing"
    case marketplace = "Marketplace"
    case events = "Events"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .general: return "bubble.left"
        case .academic: return "book"
        case .social: return "person.2"
        case .housing: return "house"
        case .marketplace: return "cart"
        case .events: return "calendar"
        }
    }
}
