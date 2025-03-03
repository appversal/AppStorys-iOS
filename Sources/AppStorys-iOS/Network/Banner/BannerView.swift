import SwiftUI

public struct BannerView: View {
    @StateObject private var apiService = APIServiceTwo()
    
    let appID: String
    let accountID: String
    let screenName: String
    let position: String    

        public init(appID: String, accountID: String, screenName: String, position: String) {
            self.appID = appID
            self.accountID = accountID
            self.screenName = screenName
            self.position = position
           
        }
    
    public var body: some View {
        ZStack(alignment: .topTrailing) {
            if let banCampaign = apiService.banCampaigns.first,
               let imageUrl = banCampaign.details?.image,
               let height = banCampaign.details?.height,
               let link = banCampaign.details?.link,
               let url = URL(string: link) {
               
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: CGFloat(height))
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: CGFloat(height))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .onAppear {
                                trackAction(campaignID: banCampaign.id, actionType: .view)
                            }
                            .onTapGesture {
                                print(banCampaign.details?.link! as Any)
                                trackAction(campaignID: banCampaign.id, actionType: .click)
                                if let link = URL(string: link), UIApplication.shared.canOpenURL(link) {
                                    UIApplication.shared.open(link)
                                }
                            }
                    case .failure:
                        Text("Failed to load image")
                    @unknown default:
                        EmptyView()
                    }
                }
                .onAppear {
                    print("Banner Height: \(height)")
                }
                .frame(height: CGFloat(height))
                .frame(maxWidth: .infinity)
                
            } else {
                ProgressView("Loading...")
                    .padding()
            }
        }
        .padding(.horizontal, 0)
        .onAppear {
            apiService.validateAccount(appID: appID, accountID: accountID,screenName: screenName,position: position)
        }
    }

    @MainActor
    func trackAction(campaignID: String, actionType: ActionType) {
        guard let accessToken = apiService.accessToken else {
            print("Access Token is missing.")
            return
        }

        Task {
            do {
                try await apiService.trackAction(type: actionType, userID: appID, campaignID: campaignID)
                print("Action tracked: \(actionType.rawValue) for campaign \(campaignID)")
            } catch {
                print("Error calling trackAction: \(error)")
            }
        }
    }


}

#Preview {
    BannerView(
        appID: "afadf960-3975-4ba2-933b-fac71ccc2002",
        accountID: "13555479-077f-445e-87f0-e6eae2e215c5",
        screenName: "Home Screen",
        position: "1"
    )
}
