// Views/Forum/PostDetailView.swift
import SwiftUI

struct PostDetailView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(post.content)
                .font(.body)
            
            Text(post.timestamp, style: .relative)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
