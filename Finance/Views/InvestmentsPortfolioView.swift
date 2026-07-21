import SwiftUI
import Models

public struct InvestmentsPortfolioView: View {
    @Bindable private var viewModel: AdvancedFinanceViewModel
    private let userId: UUID
    
    @State private var assetName = ""
    @State private var assetType = "Stock"
    @State private var buyPrice = ""
    @State private var quantity = ""
    @State private var currentPrice = ""
    @State private var successAlert = false
    
    public init(viewModel: AdvancedFinanceViewModel, userId: UUID) {
        self.viewModel = viewModel
        self.userId = userId
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Portfolio Stats Card
                portfolioStatsCard()
                
                // Add Investment Form
                addAssetForm()
                
                // Asset holdings list
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("PORTFOLIO ASSETS HOLDINGS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                            .tracking(1.0)
                            .padding(.leading, 8)
                        
                        ForEach(viewModel.investments) { asset in
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(asset.assetName)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("\(asset.assetType) • \(Int(asset.quantity)) shares")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 6) {
                                    let totalVal = asset.currentPrice * asset.quantity
                                    Text(String(format: "$%.0f", totalVal))
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    let gains = (asset.currentPrice - asset.buyPrice) * asset.quantity
                                    Text(String(format: "%@$%.0f", gains >= 0 ? "+" : "", gains))
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(gains >= 0 ? Color(hex: "#30D158") : Color(hex: "#FF453A"))
                                }
                            }
                            .padding()
                            .background(Color(hex: "#1C1C1E").opacity(0.7))
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationTitle("Assets Portfolio")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func portfolioStatsCard() -> some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("PORTFOLIO VALUE")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.gray)
                Text(String(format: "$%.0f", viewModel.investmentPortfolioValue))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("NET GAINS")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.gray)
                Text(String(format: "%@$%.0f", viewModel.investmentNetGains >= 0 ? "+" : "", viewModel.investmentNetGains))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(viewModel.investmentNetGains >= 0 ? Color(hex: "#30D158") : Color(hex: "#FF453A"))
            }
        }
        .padding()
        .background(Color(hex: "#1C1C1E"))
        .cornerRadius(16)
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    private func addAssetForm() -> some View {
        VStack(spacing: 12) {
            TextField("", text: $assetName, prompt: Text("Asset Name (e.g. MSFT)").foregroundColor(.gray))
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                TextField("", text: $buyPrice, prompt: Text("Buy Price ($)").foregroundColor(.gray))
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                
                TextField("", text: $quantity, prompt: Text("Quantity").foregroundColor(.gray))
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .foregroundColor(.white)
            }
            
            Picker("", selection: $assetType) {
                Text("Stock").tag("Stock")
                Text("Mutual Fund").tag("Mutual Fund")
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if successAlert {
                Text("Asset holding logged successfully!")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#30D158"))
            }
            
            Button("Log Investment") {
                if let price = Double(buyPrice), let qty = Double(quantity) {
                    let asset = AssetInvestment(userId: userId, assetName: assetName, assetType: assetType, buyPrice: price, quantity: qty, currentPrice: price)
                    try? viewModel.saveInvestment(asset)
                    assetName = ""
                    buyPrice = ""
                    quantity = ""
                    successAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        successAlert = false
                    }
                    viewModel.loadAllData(forUser: userId)
                }
            }
            .font(.system(size: 17, weight: .bold))
            .frame(maxWidth: .infinity)
            .padding()
            .background(!assetName.isEmpty && !buyPrice.isEmpty ? Color(hex: "#0A84FF") : Color.gray.opacity(0.2))
            .foregroundColor(!assetName.isEmpty && !buyPrice.isEmpty ? .black : .gray)
            .cornerRadius(12)
            .disabled(assetName.isEmpty || buyPrice.isEmpty)
        }
        .padding()
        .background(Color(hex: "#1C1C1E"))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}
extension AssetInvestment: Identifiable {}
