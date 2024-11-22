// Views/Forum/CommentRowView.swift
import SwiftUI

struct CommentRowView: View {
    let comment: Comment
    let isEditing: Bool
    @Binding var editText: String
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onSave: () -> Void
    let onCancel: () -> Void
    let currentUserId: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isEditing {
                TextField("Edit comment", text: $editText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack {
                    Button("Save") {
                        onSave()
                    }
                    Button("Cancel") {
                        onCancel()
                    }
                }
            } else {
                Text(comment.content)
                    .font(.body)
                
                HStack {
                    Text(comment.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if comment.authorId == currentUserId {
                        Spacer()
                        
                        Button(action: onEdit) {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
