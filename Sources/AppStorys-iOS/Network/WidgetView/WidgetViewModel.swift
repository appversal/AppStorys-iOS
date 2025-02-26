import SwiftUI

@MainActor
final class WidgetViewModel: ObservableObject {

    @Published var imageUrls: [String] = []
    @Published var widgetHeight: CGFloat = 150

    private let apiService: APIService
    private let appID: String
    private let accountID: String
    private let screenName: String
    private let widgetCampaignType = "WID"

    init(appID: String, accountID: String, screenName: String) {
        self.appID = appID
        self.accountID = accountID
        self.screenName = screenName
        self.apiService = APIService()
    }

    func viewDidLoad() {
        Task {
            do {
                let validatedAccount = try await apiService.validateAccount(appID: appID, accountID: accountID)
                guard validatedAccount else {
                    return
                }

                let campaignList = try await apiService.getCampaignList(forScreen: screenName)
                let campaigns = try await apiService.getCampaigns(campaignList: campaignList)

                guard let widgetCampaigns = campaigns.first(where: {$0.campaignType == widgetCampaignType }) else { return
                }

                guard let campaignDetails =  widgetCampaigns.details.details else { return }
                let widgetHeight = CGFloat(campaignDetails.height ?? 0)
                let imagesURLs = campaignDetails.widgetImages.sorted { $0.order < $1.order }.map { $0.imageURL }
                
                await MainActor.run { [weak self ] in
                    self?.widgetHeight = widgetHeight
                    self?.imageUrls = imagesURLs
                }
            } catch {
                print(error)
            }
        }
    }
}
