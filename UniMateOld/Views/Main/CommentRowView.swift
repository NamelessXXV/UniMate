// Views/Forum/CommentRowView.swift
import SwiftUI

struct CommentRowView: View {
    let comment: Comment
    let username: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(comment.content)
                .font(.body)
            
            HStack {
                Text(username)
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text("•")
                    .foregroundColor(.gray)
                
                Text(comment.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}
