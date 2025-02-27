//
//  SwiftUIView.swift
//  AppStorys-iOS
//
//  Created by Darshika Gupta on 27/02/25.
//

//import SwiftUI
//import SafariServices
//
//struct CampaignBanner {
//    let id: String
//    let campaignType: String // "BAN"
//    let details: BannerDetails
//}
//
//struct BannerDetails {
//    let id: String
//    let image: String
//    let height: CGFloat?
//    let link: String?
//}
//
//struct OverlayBanner: View {
//    let userId: String
//    let userData: UserData? // Replace with your actual user model
//
//    @State private var currentBanner: CampaignBanner?
//    @State private var showBanner: Bool = true
//
//    var body: some View {
//        if let banner = currentBanner, showBanner {
//            VStack {
//                Spacer()
//
//                ZStack(alignment: .topTrailing) {
//                    Button(action: {
//                        if let urlString = banner.details.link, let url = URL(string: urlString) {
//                            AppStorys.trackUserAction(userId, banner.id, "CLK")
//                            openURL(url)
//                        }
//                    }) {
//                        AsyncImage(url: URL(string: banner.details.image)) { phase in
//                            switch phase {
//                            case .empty:
//                                placeholderView
//                            case .success(let image):
//                                image
//                                    .resizable()
//                                    .scaledToFit()
//                            case .failure:
//                                placeholderView
//                            @unknown default:
//                                placeholderView
//                            }
//                        }
//                        .frame(width: UIScreen.main.bounds.width - 24,
//                               height: banner.details.height ?? 92)
//                        .cornerRadius(6)
//                    }
//                    .padding(.horizontal, 12)
//
//                    // Close button
//                    Button(action: {
//                        showBanner = false
//                    }) {
//                        Image(systemName: "xmark.circle.fill")
//                            .foregroundColor(.white)
//                            .background(Circle().fill(Color.black))
//                            .frame(width: 24, height: 24)
//                    }
//                    .padding(8)
//                }
//            }
//            .padding(.bottom, 12)
//            .onAppear {
//                loadBanner()
//            }
//        }
//    }
//
//    private var placeholderView: some View {
//        Rectangle()
//            .fill(Color.gray.opacity(0.3))
//            .frame(width: UIScreen.main.bounds.width - 24, height: 92)
//            .cornerRadius(6)
//    }
//
//    private func loadBanner() {
//        guard let campaigns = userData?.campaigns else { return }
//
//        if let campaignData = campaigns.first(where: { $0["campaign_type"] as? String == "BAN" }) {
//            if let details = campaignData["details"] as? [String: Any] {
//                let banner = CampaignBanner(
//                    id: campaignData["id"] as? String ?? "",
//                    campaignType: "BAN",
//                    details: BannerDetails(
//                        id: details["id"] as? String ?? "",
//                        image: details["image"] as? String ?? "",
//                        height: details["height"] as? CGFloat,
//                        link: details["link"] as? String
//                    )
//                )
//
//                currentBanner = banner
//                AppStorys.trackUserAction(userId, banner.id, "IMP")
//            }
//        }
//    }
//
//    private func openURL(_ url: URL) {
//        UIApplication.shared.open(url)
//    }
//}
//
//// Mock user data model
//struct UserData {
//    let campaigns: [[String: Any]]
//}
//
//// Tracking actions (Placeholder function)
//struct AppStorys {
//    static func trackUserAction(_ userId: String, _ bannerId: String, _ action: String) {
//        print("Tracking action: \(action) for user \(userId) and banner \(bannerId)")
//    }
//}
//
//// MARK: - SwiftUI Preview
//struct OverlayBanner_Previews: PreviewProvider {
//    static var previews: some View {
//        OverlayBanner(
//            userId: "12345",
//            userData: UserData(
//                campaigns: [
//                    [
//                        "id": "campaign_001",
//                        "campaign_type": "BAN",
//                        "details": [
//                            "id": "banner_001",
//                            "image": "https://via.placeholder.com/350x150", // Sample placeholder image
//                            "height": 100,
//                            "link": "https://example.com"
//                        ]
//                    ]
//                ]
//            )
//        )
//        .previewLayout(.sizeThatFits)
//    }
//}
import SwiftUI

struct BannerTwoView: View {
    @StateObject private var viewModel: CampaignViewModel
    @Binding var showBanner: Bool
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    
    @State private var bannerImageUrl: String?
    @State private var bannerLink: String?

    init(showBanner: Binding<Bool>, appID: String, accountID: String, screenName: String, width: CGFloat, height: CGFloat, cornerRadius: CGFloat) {
        self._showBanner = showBanner
        self._viewModel = StateObject(wrappedValue: CampaignViewModel(appID: appID, accountID: accountID, screenName: screenName))
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        if showBanner, let imageUrl = bannerImageUrl {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: height)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    case .failure:
                        Color.gray
                            .frame(width: width, height: height)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    case .empty:
                        ProgressView()
                            .frame(width: width, height: height)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    @unknown default:
                        EmptyView()
                    }
                }
                .onTapGesture {
                    if let bannerLink = bannerLink, let url = URL(string: bannerLink) {
                        UIApplication.shared.open(url)
                    }
                }
                .background(RoundedRectangle(cornerRadius: cornerRadius).fill(Color.white))
                
                // Close Button
                Button(action: {
                    showBanner = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                .padding(8)
            }
            .padding(.horizontal, 7)
            .padding(.top, 7)
            .frame(maxWidth: .infinity, alignment: .bottom)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .onAppear {
                viewModel.fetchCampaigns()
            }
            .onReceive(viewModel.$campaigns) { campaigns in
                DispatchQueue.main.async {
                    if campaigns.first(where: { $0.campaignType == "BAN" }) != nil {
                        bannerImageUrl = "https://img.freepik.com/premium-psd/mobile-app-promotion-social-media-post-banner-template_350109-220.jpg"
                        bannerLink = "https://img.freepik.com/premium-psd/mobile-app-promotion-social-media-post-banner-template_350109-220.jpg"
                    }
                }
            }

        }
    }
}

// MARK: - **Preview**
struct BannerTwoView_Previews: PreviewProvider {
    static var previews: some View {
        BannerPreviewWrapper()
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.white) // Adds background to ensure visibility
    }
}

struct BannerPreviewWrapper: View {
    @State private var showBanner = true

    var body: some View {
        BannerTwoView(
            showBanner: $showBanner,
            appID: "afadf960-3975-4ba2-933b-fac71ccc2002",
            accountID: "13555479-077f-445e-87f0-e6eae2e215c5",
            screenName: "Home Screen",
            width: 393,
            height: 60,
            cornerRadius: 15
        )
    }
}
