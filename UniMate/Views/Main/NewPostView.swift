// Views/Forum/NewPostView.swift
import SwiftUI

struct NewPostView: View {
    @ObservedObject var viewModel: ForumViewModel
    @Binding var isPresented: Bool
    @Binding var title: String
    @Binding var content: String
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Enter title", text: $title)
                }
                
                Section(header: Text("Content")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("New Post")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Post") {
                    if let userId = authViewModel.currentUser?.id {
                        Task {
                            await viewModel.createPost(
                                title: title,
                                content: content,
                                userId: userId
                            )
                            title = ""
                            content = ""
                            isPresented = false
                        }
                    }
                }
                .disabled(title.isEmpty || content.isEmpty)
            )
        }
    }
}

// Preview Provider
struct CommentsView_Previews: PreviewProvider {
    static var previews: some View {
        let samplePost = Post(
            id: "1",
            authorId: "user1",
            title: "Sample Post",
            content: "This is a sample post content",
            timestamp: Date()
        )
        
        CommentsView(
            viewModel: ForumViewModel(),
            post: samplePost,
            isPresented: .constant(true)
        )
        .environmentObject(AuthViewModel())
    }
}

struct NewPostView_Previews: PreviewProvider {
    static var previews: some View {
        NewPostView(
            viewModel: ForumViewModel(),
            isPresented: .constant(true),
            title: .constant(""),
            content: .constant("")
        )
        .environmentObject(AuthViewModel())
    }
}
