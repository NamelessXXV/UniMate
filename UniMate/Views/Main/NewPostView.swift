// Views/Forum/NewPostView.swift
import SwiftUI

struct NewPostView: View {
    @ObservedObject var viewModel: ForumViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var isPresented: Bool
    @Binding var title: String
    @Binding var content: String
    @State private var selectedPostCategory: PostCategory = .general // Renamed to be clear this is for new post
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Post Details")) {
                    TextField("Title", text: $title)
                    TextEditor(text: $content)
                        .frame(height: 200)
                }
                
                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedPostCategory) {
                        ForEach(PostCategory.allCases.filter { $0 != .all }) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
            }
            .navigationTitle("New Post")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Post") {
                    guard let userId = authViewModel.currentUser?.id else { return }
                    Task {
                        // Pass the selectedPostCategory here
                        await viewModel.createPost(title: title,
                                                content: content,
                                                userId: userId,
                                                category: selectedPostCategory)
                        title = ""
                        content = ""
                        isPresented = false
                    }
                }
                .disabled(title.isEmpty || content.isEmpty)
            )
        }
    }
}
