import Foundation

class APIService: @unchecked Sendable {
    private let baseURL = "https://backend.appstorys.com/api/v1/users/"
    private var accessToken: String?

    private enum Endpoints: String {
        case validateAccount = "validate-account/"
        case trackScreen = "track-screen/"
        case trackUser = "track-user/"
        case trackAction = "track-action/"
    }

    func validateAccount(appID: String, accountID: String) async throws -> Bool {
        let url = URL(string: "\(baseURL)\(Endpoints.validateAccount.rawValue)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: String] = ["app_id": appID, "account_id": accountID]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, _) = try await URLSession.shared.data(for: request)
        let decodedResponse = try JSONDecoder().decode(AccessTokenResponse.self, from: data)
        self.accessToken = decodedResponse.accessToken
        return accessToken != nil
    }

    func getCampaignList(forScreen screenName: String, position: String) async throws -> [String] {
        let requestBody = TrackScreenRequest(screen_name: screenName, position_list: [position])
        let response: CampaignListResponse = try await performRequest(
            endpoint: Endpoints.trackScreen.rawValue,
            body: requestBody
        )
        return response.campaignList
    }

    func getCampaigns(campaignList: [String]) async throws -> [Campaign] {
        let userId = UUID().uuidString
        let requestBody = TrackUserRequest(user_id: userId, campaign_list: campaignList)
        let response: CampaignDataResponse = try await performRequest(
            endpoint: Endpoints.trackUser.rawValue,
            body: requestBody
        )
        return response.campaigns
    }

    func trackAction(type: ActionType, userID: String, campaignID: String, widgetID: String) async throws {
        let requestBody = TrackActionRequest(campaign_id: campaignID, user_id: userID, event_type: type.rawValue, widget_id: widgetID)

        let response: TrackActionResponse = try await performRequest(
            endpoint: Endpoints.trackAction.rawValue,
            body: requestBody
        )
    }

    private func performRequest<T: Decodable>(
        endpoint: String,
        method: String = "POST",
        body: Encodable? = nil
    ) async throws -> T {
        guard let accessToken else {
            throw APIError.noAccessToken
        }

        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    private struct TrackUserRequest: Codable {
        let user_id: String
        let campaign_list: [String]
    }

    private struct TrackActionRequest: Codable {
        let campaign_id: String
        let user_id: String
        let event_type: String
        let widget_id: String
    }

    private struct TrackScreenRequest: Codable {
        let screen_name: String
        let position_list: [String]
    }
}

enum APIError: Error {
    case noAccessToken
    case invalidResponse
    case invalidURL
}

enum ActionType: String {
    case view = "IMP"
    case click = "CLK"
}
