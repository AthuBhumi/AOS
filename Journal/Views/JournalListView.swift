import SwiftUI
import Models

public struct JournalListView: View {
    @State private var viewModel: JournalViewModel
    private let userId: UUID
    
    public init(viewModel: JournalViewModel, userId: UUID) {
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
                    Button("Retry") { viewModel.loadEntries() }
                        .foregroundColor(Color(hex: "#0A84FF"))
                }
                
            case .loaded(let entries), .reframing:
                VStack(spacing: 16) {
                    // Header Card
                    HStack {
                        Text("DAILY REFLECTION LOGS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                            .tracking(1.0)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    if entries.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "pencil.and.outline")
                                .font(.system(size: 44))
                                .foregroundColor(.gray)
                            Text("No journals logged yet.")
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 80)
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(entries) { entry in
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack {
                                            Text(entry.title)
                                                .font(.system(size: 17, weight: .bold))
                                                .foregroundColor(.white)
                                            Spacer()
                                            
                                            // Mood Badge
                                            Text(String(format: "%.1f", entry.moodScore))
                                                .font(.system(size: 12, weight: .bold))
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(moodColor(entry.moodScore).opacity(0.2))
                                                .foregroundColor(moodColor(entry.moodScore))
                                                .cornerRadius(6)
                                        }
                                        
                                        Text(entry.content)
                                            .font(.system(size: 13))
                                            .foregroundColor(.gray)
                                            .lineLimit(2)
                                        
                                        // Cognitive distortion alert
                                        if let distortion = entry.detectedDistortion {
                                            HStack(spacing: 4) {
                                                Image(systemName: "brain.head.profile")
                                                    .font(.system(size: 11))
                                                Text("\(distortion) detected")
                                                    .font(.system(size: 11, weight: .bold))
                                            }
                                            .foregroundColor(Color(hex: "#FFD60A"))
                                        }
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
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Add Entry Navigation
                    NavigationLink(destination: JournalEditorView(viewModel: viewModel, userId: userId)) {
                        Text("Write Daily Reflection")
                            .font(.system(size: 17, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#0A84FF"))
                            .foregroundColor(.black)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear {
            viewModel.loadEntries()
        }
        .navigationTitle("Journal Logs")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func moodColor(_ score: Double) -> Color {
        if score >= 7.0 {
            return Color(hex: "#30D158")
        } else if score >= 4.0 {
            return Color(hex: "#FFD60A")
        } else {
            return Color(hex: "#FF453A")
        }
    }
}
extension JournalEntry: Identifiable {}
