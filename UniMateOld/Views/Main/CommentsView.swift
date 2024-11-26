// Views/Forum/CommentsView.swift
import SwiftUI

struct CommentsView: View {
    @ObservedObject var viewModel: ForumViewModel
    let post: Post
    @Binding var isPresented: Bool
    @State private var newCommentText = ""
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            VStack {
                PostDetailView(post: post)
                    .padding()
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.comments[post.id] ?? []) { comment in
                            CommentRowView(
                                comment: comment,
                                username: viewModel.usernames[comment.authorId] ?? "Unknown User"
                            )
                        }
                    }
                    
                    VStack {
                        HStack {
                            TextField("Add a comment...", text: $newCommentText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button(action: {
                                guard !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                                      let userId = authViewModel.currentUser?.id else { return }
                                
                                Task {
                                    await viewModel.addComment(
                                        postId: post.id,
                                        userId: userId,
                                        content: newCommentText
                                    )
                                    newCommentText = ""
                                }
                            }) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            }
                            .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        .padding()
                    }
                    .background(Color(UIColor.systemBackground))
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(UIColor.systemGray4)),
                        alignment: .top
                    )
                }
            }
            .navigationTitle("Comments")
            .navigationBarItems(
                leading: Button("Close") {
                    isPresented = false
                }
            )
        }
        .task {
            isLoading = true
            await viewModel.fetchComments(for: post.id)
            isLoading = false
        }
    }
}
