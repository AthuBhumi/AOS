import SwiftUI
import Models

public struct BookListView: View {
    @State private var viewModel: ReadingViewModel
    private let userId: UUID
    @State private var showAddBookSheet = false
    @State private var newTitle = ""
    @State private var newAuthor = ""
    @State private var newPages = ""
    
    public init(viewModel: ReadingViewModel, userId: UUID) {
        _viewModel = State(initialValue: viewModel)
        self.userId = userId
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
            case .failure(let error):
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 44))
                        .foregroundColor(Color(hex: "#FF453A"))
                    Text(error)
                        .foregroundColor(.white)
                    Button("Retry") { viewModel.loadBooks() }
                        .foregroundColor(Color(hex: "#0A84FF"))
                }
                
            case .loadedBooks, .loadedReviewQueue:
                VStack(spacing: 20) {
                    // Reviews Due Banner Card
                    reviewQueueBanner()
                    
                    // Book catalog list
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.books) { book in
                                NavigationLink(destination: BookDetailView(viewModel: viewModel, book: book, userId: userId)) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(book.title)
                                                .font(.system(size: 17, weight: .bold))
                                                .foregroundColor(.white)
                                            Text(book.author)
                                                .font(.system(size: 13))
                                                .foregroundColor(.gray)
                                            
                                            // Progress bar
                                            let progress = Double(book.completedPages) / Double(book.totalPages)
                                            ProgressView(value: progress)
                                                .accentColor(Color(hex: "#BF5AF2"))
                                                .scaleEffect(x: 1, y: 1.2, anchor: .leading)
                                                .padding(.top, 4)
                                        }
                                        Spacer()
                                        
                                        Text("\(book.completedPages)/\(book.totalPages) pgs")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color(hex: "#1C1C1E").opacity(0.7))
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadBooks()
        }
        .navigationTitle("Reading Library")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddBookSheet = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showAddBookSheet) {
            addBookSheetLayout()
        }
    }
    
    private func reviewQueueBanner() -> some View {
        NavigationLink(destination: ActiveRecallView(viewModel: viewModel, userId: userId)) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ACTIVE RECALL REVIEWS")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "#0A84FF"))
                        .tracking(1.0)
                    Text("Recall reviews due today")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                }
                Spacer()
                Image(systemName: "square.stack.3d.up.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "#0A84FF"))
            }
            .padding()
            .background(Color(hex: "#0A84FF").opacity(0.15))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "#0A84FF").opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
    }
    
    private func addBookSheetLayout() -> some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)
                
                Text("Add New Book")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    TextField("", text: $newTitle, prompt: Text("Book Title").foregroundColor(.gray))
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    TextField("", text: $newAuthor, prompt: Text("Author").foregroundColor(.gray))
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    TextField("", text: $newPages, prompt: Text("Total Pages").foregroundColor(.gray))
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    Button("Save Book") {
                        if let total = Int(newPages) {
                            viewModel.addNewBook(title: newTitle, author: newAuthor, pages: total)
                            newTitle = ""
                            newAuthor = ""
                            newPages = ""
                            showAddBookSheet = false
                        }
                    }
                    .font(.system(size: 17, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#0A84FF"))
                    .foregroundColor(.black)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                Spacer()
            }
        }
    }
}
extension Book: Identifiable {}
