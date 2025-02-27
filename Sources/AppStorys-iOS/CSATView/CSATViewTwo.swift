//
//  SwiftUIView.swift
//  AppStorys-iOS
//
//  Created by Darshika Gupta on 27/02/25.
//

//import SwiftUI
//
//// MARK: - CSAT Details Model
//struct CsatDetails {
//    let id: String
//    let title: String
//    let height: CGFloat?
//    let width: CGFloat?
//    let styling: [String: String]
//    let thankyouImage: String?
//    let thankyouText: String
//    let thankyouDescription: String
//    let descriptionText: String
//    let feedbackOptions: [String: String]
//    let campaign: String
//}
//
//// MARK: - CSAT Campaign Model
//struct CampaignCsat {
//    let id: String
//    let campaignType: String
//    let details: CsatDetails
//}
//
//// MARK: - CSAT View
//struct CsatView: View {
//    let userId: String
//    let currentCsat: CampaignCsat?
//    
//    @State private var showCSAT: Bool = true
//    @State private var selectedStars: Int = 0
//    @State private var showThanks: Bool = false
//    @State private var showFeedback: Bool = false
//    @State private var selectedOption: String?
//    @State private var csatLoaded: Bool = false
//    
//    init(userId: String, currentCsat: CampaignCsat?) {
//        self.userId = userId
//        self.currentCsat = currentCsat
//        _csatLoaded = State(initialValue: UserDefaults.standard.bool(forKey: "csat_loaded"))
//    }
//    
//    var body: some View {
//        if !showCSAT || currentCsat == nil || csatLoaded {
//            EmptyView()
//        } else {
//            VStack {
//                if showThanks {
//                    thanksView()
//                } else {
//                    surveyView()
//                }
//            }
//            .padding()
//            .background(hexToColor(currentCsat!.details.styling["csatBackgroundColor"] ?? "#FFFFFF"))
//            .cornerRadius(24)
//            .overlay(
//                RoundedRectangle(cornerRadius: 24)
//                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//            )
//            .padding()
//            .onAppear {
//                scheduleCsatDisplay()
//            }
//        }
//    }
//    
//    // MARK: - Survey View
//    @ViewBuilder
//    private func surveyView() -> some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text(currentCsat!.details.title)
//                .font(.title2)
//                .fontWeight(.bold)
//                .foregroundColor(hexToColor(currentCsat!.details.styling["csatTitleColor"] ?? "#000000"))
//            
//            Text(currentCsat!.details.descriptionText)
//                .foregroundColor(hexToColor(currentCsat!.details.styling["csatDescriptionTextColor"] ?? "#666666"))
//            
//            HStack {
//                ForEach(1..<6) { index in
//                    Image(systemName: index <= selectedStars ? "star.fill" : "star")
//                        .foregroundColor(.yellow)
//                        .font(.title)
//                        .onTapGesture {
//                            selectedStars = index
//                            if index >= 4 {
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                                    showThanks = true
//                                }
//                            }
//                        }
//                }
//            }
//        }
//    }
//    
//    // MARK: - Thanks View
//    @ViewBuilder
//    private func thanksView() -> some View {
//        VStack {
//            if let imageUrl = currentCsat!.details.thankyouImage {
//                AsyncImage(url: URL(string: imageUrl)) { image in
//                    image.resizable()
//                        .scaledToFit()
//                        .frame(height: 66)
//                } placeholder: {
//                    ProgressView()
//                }
//            }
//            
//            Text(currentCsat!.details.thankyouText)
//                .font(.title3)
//                .fontWeight(.bold)
//                .foregroundColor(Color.gray)
//            
//            Text(currentCsat!.details.thankyouDescription)
//                .foregroundColor(Color.gray)
//            
//            Button(action: {
//                showCSAT = false
//                UserDefaults.standard.setValue(true, forKey: "csat_loaded")
//            }) {
//                Text("Done")
//                    .font(.headline)
//                    .foregroundColor(hexToColor(currentCsat!.details.styling["csatCtaTextColor"] ?? "#FFFFFF"))
//                    .padding()
//                    .background(hexToColor(currentCsat!.details.styling["csatCtaBackgroundColor"] ?? "#FF0000"))
//                    .cornerRadius(20)
//            }
//        }
//    }
//    
//    // MARK: - CSAT Delay Logic
//    private func scheduleCsatDisplay() {
//        let delay = Int(currentCsat?.details.styling["delayDisplay"] ?? "0") ?? 0
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) {
//            if !csatLoaded {
//                showCSAT = true
//            }
//        }
//    }
//    
//    // MARK: - Color Conversion
//    private func hexToColor(_ hex: String) -> Color {
//        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
//        if hexSanitized.hasPrefix("#") {
//            hexSanitized.remove(at: hexSanitized.startIndex)
//        }
//        var rgb: UInt64 = 0
//        Scanner(string: hexSanitized).scanHexInt64(&rgb)
//        
//        return Color(
//            red: Double((rgb >> 16) & 0xFF) / 255.0,
//            green: Double((rgb >> 8) & 0xFF) / 255.0,
//            blue: Double(rgb & 0xFF) / 255.0
//        )
//    }
//}
//
//struct CsatView_Previews: PreviewProvider {
//    static var previews: some View {
//        CsatView(
//            userId: "12345",
//            currentCsat: CampaignCsat(
//                id: "csat-001",
//                campaignType: "CSAT",
//                details: CsatDetails(
//                    id: "details-001",
//                    title: "Rate Your Experience",
//                    height: nil,
//                    width: nil,
//                    styling: [
//                        "csatBackgroundColor": "#F8F8F8",
//                        "csatTitleColor": "#333333",
//                        "csatDescriptionTextColor": "#666666",
//                        "csatCtaBackgroundColor": "#FF5733",
//                        "csatCtaTextColor": "#FFFFFF"
//                    ],
//                    thankyouImage: nil,
//                    thankyouText: "Thank You!",
//                    thankyouDescription: "Your feedback helps us improve!",
//                    descriptionText: "How was your experience?",
//                    feedbackOptions: [:],
//                    campaign: "CSAT Campaign"
//                )
//            )
//        )
//        .previewLayout(.sizeThatFits) // Helps with layout issues
//        .environment(\.colorScheme, .light) // Optional: Preview in light mode
//    }
//}
