import SwiftUI
import Models

public struct JournalEditorView: View {
    @Bindable private var viewModel: JournalViewModel
    private let userId: UUID
    @Environment(\.dismiss) private var dismiss
    @State private var entryTitle = ""
    @State private var targetEntryForReframe: JournalEntry?
    @State private var showReframeSheet = false
    
    public init(viewModel: JournalViewModel, userId: UUID) {
        self.viewModel = viewModel
        self.userId = userId
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ScrollView {
                    VStack(spacing: 16) {
                        // Title Input
                        TextField("", text: $entryTitle, prompt: Text("Title").foregroundColor(.gray))
                            .font(.system(size: 20, weight: .bold))
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .padding(.top, 16)
                        
                        // Mood Slider Card
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Mood rating:")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(String(format: "%.1f", viewModel.moodScore))
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color(hex: "#0A84FF"))
                            }
                            
                            Slider(value: $viewModel.moodScore, in: 0.0...10.0, step: 0.5)
                                .accentColor(Color(hex: "#0A84FF"))
                        }
                        .padding()
                        .background(Color(hex: "#1C1C1E"))
                        .cornerRadius(12)
                        
                        // Text Editor Buffer
                        TextEditor(text: $viewModel.contentBuffer)
                            .frame(minHeight: 240)
                            .padding(8)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                }
                
                // Submit Button
                Button("Save Entry") {
                    viewModel.commitEntry(title: entryTitle, forUser: userId) { entry in
                        if entry.detectedDistortion != nil {
                            targetEntryForReframe = entry
                            showReframeSheet = true
                        } else {
                            dismiss()
                        }
                    }
                }
                .font(.system(size: 17, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "#0A84FF"))
                .foregroundColor(.black)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showReframeSheet) {
            if let entry = targetEntryForReframe {
                CBTReframingView(viewModel: viewModel, entry: entry, userId: userId, onComplete: {
                    showReframeSheet = false
                    dismiss()
                })
            }
        }
    }
}
