import SwiftUI
import Models

public struct LeanCanvasView: View {
    @State private var viewModel: BusinessViewModel
    private let userId: UUID
    @State private var selectedBoxKey: String?
    @State private var selectedBoxTitle = ""
    @State private var selectedBoxContent = ""
    @State private var showEditSheet = false
    
    public init(viewModel: BusinessViewModel, userId: UUID) {
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
                    Button("Retry") { viewModel.loadCanvas(forUser: userId) }
                        .foregroundColor(Color(hex: "#0A84FF"))
                }
                
            case .loaded(let canvas):
                ScrollView {
                    VStack(spacing: 20) {
                        // Revision overdue warning
                        if viewModel.isRevisionOverdue {
                            revisionOverdueBanner()
                        }
                        
                        // Completeness percentage
                        completenessHeaderCard()
                        
                        // 9 Boxes Grid
                        VStack(spacing: 12) {
                            boxRow(title: "1. Problem", value: canvas.problem, key: "problem")
                            boxRow(title: "2. Solution", value: canvas.solution, key: "solution")
                            boxRow(title: "3. Unique Value Prop", value: canvas.uniqueValueProp, key: "uvp")
                            boxRow(title: "4. Unfair Advantage", value: canvas.unfairAdvantage, key: "advantage")
                            boxRow(title: "5. Customer Segments", value: canvas.customerSegments, key: "segments")
                            boxRow(title: "6. Channels", value: canvas.channels, key: "channels")
                            boxRow(title: "7. Key Metrics", value: canvas.keyMetrics, key: "metrics")
                            boxRow(title: "8. Cost Structure", value: canvas.costStructure, key: "cost")
                            boxRow(title: "9. Revenue Streams", value: canvas.revenueStreams, key: "revenue")
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadCanvas(forUser: userId)
        }
        .navigationTitle("Lean Canvas")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditSheet) {
            if let key = selectedBoxKey {
                EditCanvasBoxView(
                    viewModel: viewModel,
                    boxKey: key,
                    boxTitle: selectedBoxTitle,
                    initialContent: selectedBoxContent,
                    userId: userId,
                    onComplete: {
                        showEditSheet = false
                        selectedBoxKey = nil
                    }
                )
            }
        }
    }
    
    private func revisionOverdueBanner() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.badge.exclamationmark")
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "#FFD60A"))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("REVISION OVERDUE")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(hex: "#FFD60A"))
                Text("Startup assumptions have not been revised in 14 days. Review validation logs.")
                    .font(.system(size: 13))
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color(hex: "#FFD60A").opacity(0.15))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#FFD60A").opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    private func completenessHeaderCard() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Assumption Validation")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text(String(format: "%.0f%% Done", viewModel.completenessScore))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: "#30D158"))
            }
            
            ProgressView(value: viewModel.completenessScore / 100.0)
                .accentColor(Color(hex: "#30D158"))
        }
        .padding()
        .background(Color(hex: "#1C1C1E"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    private func boxRow(title: String, value: String, key: String) -> some View {
        Button(action: {
            selectedBoxKey = key
            selectedBoxTitle = title
            selectedBoxContent = value
            showEditSheet = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "#0A84FF"))
                    
                    if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("Add validation assumptions...")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        Text(value)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer()
                Image(systemName: "pencil")
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "#1C1C1E").opacity(0.7))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}
extension LeanCanvas: Identifiable {}
