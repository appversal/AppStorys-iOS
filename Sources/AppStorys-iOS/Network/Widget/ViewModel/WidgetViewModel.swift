import Combine
import SwiftUI

@MainActor
final class WidgetViewModel: ObservableObject {

    @Published var images: [WidgetImage] = []
    @Published var widgetHeight: CGFloat = 150
    @Published var selectedIndex = 0

    private let apiService: APIService
    private let appID: String
    private let accountID: String
    private let screenName: String
    private let position: String
    private let widgetCampaignType = "WID"


    private var cancellables: Set<AnyCancellable> = []
    private var campaignID: String?

    init(appID: String, accountID: String, screenName: String, position: String) {
        self.appID = appID
        self.accountID = accountID
        self.screenName = screenName
        self.position = position
        self.apiService = APIService()
        setupBindings()
    }

    private func setupBindings() {
        $selectedIndex.sink { [weak self] index in
            self?.didViewWidgetImage(at: index)
        }
        .store(in: &cancellables)
    }

    func viewDidLoad() {
        Task {
            do {
                let validatedAccount = try await apiService.validateAccount(appID: appID, accountID: accountID)
                guard validatedAccount else {
                    return
                }

                let campaignList = try await apiService.getCampaignList(forScreen: screenName, position: position)
                let campaigns = try await apiService.getCampaigns(campaignList: campaignList)

                guard let widgetCampaign = campaigns.first(where: {$0.campaignType == widgetCampaignType }) else { return
                }
                self.campaignID = widgetCampaign.id
                guard let campaignDetails =  widgetCampaign.details.details else { return }
                let widgetHeight = CGFloat(campaignDetails.height ?? 0)
                let images = campaignDetails.widgetImages.sorted { $0.order < $1.order }

                await MainActor.run { [weak self ] in
                    self?.widgetHeight = widgetHeight
                    self?.images = images
                    self?.didViewWidgetImage(at: 0)
                }
            } catch {
                print(error)
            }
        }
    }

    func didViewWidgetImage(at index: Int) {
        guard let campaignID, let viewedImage = images[safe: index] else { return }
        Task {
            try await apiService.trackAction(type: .view, userID: appID, campaignID: campaignID, widgetID: viewedImage.id)
        }
    }

    func didTapWidgetImage(at index: Int) {
        guard let campaignID, let tappedImage = images[safe: index] else { return }
        Task {
            try await apiService.trackAction(type: .click, userID: appID, campaignID: campaignID, widgetID: tappedImage.id)
        }
    }
}

extension Collection {
    // Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
