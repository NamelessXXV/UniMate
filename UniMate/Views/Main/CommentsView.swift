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
                PostDetailView(viewModel: viewModel, post: post)
                    .padding()
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.comments[post.id ?? ""] ?? []) { comment in
                            CommentRowView(
                                comment: comment,
                                username: viewModel.usernames[comment.authorId] ?? "Unknown User",
                                userPhotoURL: viewModel.userPhotos[comment.authorId]
                            )
                        }
                    }
                    
                    VStack {
                        HStack {
                            TextField("Add a comment...", text: $newCommentText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button(action: {
                                guard !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                                      let userId = authViewModel.currentUser?.id,
                                      let postId = post.id else { return }
                                
                                Task {
                                    await viewModel.addComment(
                                        postId: postId,
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
            if let postId = post.id {
                await viewModel.fetchComments(for: postId)
                // Fetch user photos for all comments
                for comment in viewModel.comments[postId] ?? [] {
                    await viewModel.fetchUserPhoto(userId: comment.authorId)
                }
            }
            isLoading = false
        }
    }
}
