import SwiftUI
import Models

public struct BookDetailView: View {
    @State private var viewModel: ReadingViewModel
    let book: Book
    private let userId: UUID
    @State private var pagesLoggedInput = ""
    @State private var logSuccess = false
    
    public init(viewModel: ReadingViewModel, book: Book, userId: UUID) {
        _viewModel = State(initialValue: viewModel)
        self.book = book
        self.userId = userId
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Book Title summary
                VStack(spacing: 8) {
                    Text(book.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    Text("by \(book.author)")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                .padding(.top, 24)
                
                // Progress stats card
                VStack(spacing: 16) {
                    HStack {
                        Text("Reading Progress")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        let progress = Double(book.completedPages) / Double(book.totalPages)
                        Text(String(format: "%.0f%%", progress * 100.0))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(hex: "#BF5AF2"))
                    }
                    
                    ProgressView(value: Double(book.completedPages) / Double(book.totalPages))
                        .accentColor(Color(hex: "#BF5AF2"))
                    
                    HStack {
                        Text("Pages Read:")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(book.completedPages) of \(book.totalPages)")
                            .foregroundColor(.white)
                    }
                }
                .padding(20)
                .background(Color(hex: "#1C1C1E"))
                .cornerRadius(16)
                .padding(.horizontal, 20)
                
                // Form log page card
                VStack(spacing: 16) {
                    Text("LOG DAILY PROGRESS")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("", text: $pagesLoggedInput, prompt: Text("Pages Read Today").foregroundColor(.gray))
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    if logSuccess {
                        Text("Pages logged successfully! +30 XP awarded.")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "#30D158"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Button(action: { logProgress() }) {
                        Text("Log Read Pages")
                            .font(.system(size: 17, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#0A84FF"))
                            .foregroundColor(.black)
                            .cornerRadius(12)
                    }
                    .disabled(pagesLoggedInput.isEmpty)
                }
                .padding(20)
                .background(Color(hex: "#1C1C1E"))
                .cornerRadius(16)
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func logProgress() {
        guard let pages = Int(pagesLoggedInput) else { return }
        viewModel.logPagesRead(forBook: book.id, pagesRead: pages, forUser: userId)
        pagesLoggedInput = ""
        logSuccess = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            logSuccess = false
        }
    }
}
