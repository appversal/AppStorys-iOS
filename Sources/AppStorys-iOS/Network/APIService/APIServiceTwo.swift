//
//  File.swift
//  AppStorys-iOS-main-3
//
//  Created by Darshika Gupta on 28/02/25.
//

import SwiftUI

struct ValidateAccountResponse: Codable {
    let access_token: String
    let refresh_token: String
}

struct TrackScreenResponse: Codable {
    let campaigns: [String]
}
@MainActor
class APIServiceTwo: ObservableObject {
    @Published var accessToken: String?
    @Published var campaigns: [String] = []
    @Published var banCampaigns: [Campaign] = [] 
    @Published var pipCampaigns: [PipCampaign] = []

    let appID = "afadf960-3975-4ba2-933b-fac71ccc2002"
     let userID = "13555479-077f-445e-87f0-e6eae2e215c5"
    
    private enum Endpoints: String {
            case validateAccount = "/validate-account/"
            case trackScreen = "/track-screen/"
            case trackUser = "/track-user/"
            case trackAction = "/track-action/"
        }
    
    func validateAccount(appID: String, accountID: String, screenName: String, position: String) {
        let url = URL(string: "https://backend.appstorys.com/api/v1/users\(Endpoints.validateAccount.rawValue)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "app_id": appID,
            "account_id": accountID
        ]
        
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(ValidateAccountResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self.accessToken = decodedResponse.access_token
                    print("Access Token: \(decodedResponse.access_token)")
                    
                    // Pass screenName and position to trackScreen
                    self.trackScreen(accessToken: decodedResponse.access_token, screenName: screenName, position: position)
                }
                
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }

    func trackScreen(accessToken: String, screenName: String, position: String) {
        let url = URL(string: "https://backend.appstorys.com/api/v1/users/track-screen/")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "screen_name": screenName,
            "position_list": [position] // Passing position as an array
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(TrackScreenResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self.campaigns = decodedResponse.campaigns
                    print("Campaigns: \(decodedResponse.campaigns)")
                    
                    // Call trackUser API after trackScreen
                    self.trackUser(accessToken: accessToken)
                }
                
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }

    
    func trackUser(accessToken: String) {
        let url = URL(string: "https://backend.appstorys.com/api/v1/users/track-user/")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "user_id": userID,
            "campaign_list": campaigns,
//            "attributes": [
//                ["age": "1"]
//            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Print the raw JSON response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON Response: \(jsonString)")
            } else {
                print("Failed to convert response to String.")
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(TrackUserResponse.self, from: data)
                let decodedResponsePip = try JSONDecoder().decode(TrackUserResponsePip.self, from: data)
                
                DispatchQueue.main.async {
                    self.banCampaigns = decodedResponse.campaigns.filter { $0.campaignType == "BAN" }
                    
                    self.pipCampaigns = decodedResponsePip.campaigns.filter { $0.campaignType == "PIP" }
                    
                    print("BAN Campaigns: \(self.banCampaigns)")
                    print("PIP Campaigns: \(self.pipCampaigns)")
                }
                
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
    
    func trackAction(type: ActionType, userID: String, campaignID: String ) async throws {
        let requestBody = TrackActionRequest(campaign_id: campaignID, user_id: userID, event_type: type.rawValue)

        // Perform the request and get the response
        let response: TrackActionResponse = try await performRequest(
            endpoint: Endpoints.trackAction.rawValue,
            body: requestBody
        )

        // Print the response for debugging purposes
        print("Response: \(response)")
    }

    
    private func performRequest<T: Decodable>(
        endpoint: String,
        method: String = "POST",
        body: Encodable? = nil
    ) async throws -> T {
        guard let accessToken else {
            throw APIError.noAccessToken
        }

        guard let url = URL(string: "https://backend.appstorys.com/api/v1/users/track-action/") else {
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
        
        // Check if the response is a valid HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Check if the status code is in the success range (200-299)
        if !(200...299).contains(httpResponse.statusCode) {
            let errorMessage = "Error with status code: \(httpResponse.statusCode)"
            print(errorMessage) // Log the status code for debugging
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


//struct SwiftUIView: View {
//    @StateObject private var apiService = APIService()
//    
//    var body: some View {
//        VStack {
//            Text("Access Token:")
//                .font(.headline)
//            Text(apiService.accessToken ?? "No Token")
//                .foregroundColor(.blue)
//                .padding()
//            
//            Text("Campaigns:")
//                .font(.headline)
//            ForEach(apiService.campaigns, id: \.self) { campaign in
//                Text(campaign)
//                    .foregroundColor(.green)
//                    .padding()
//            }
//            
//            Button("Validate Account & Track User") {
//                apiService.validateAccount( appID: "afadf960-3975-4ba2-933b-fac71ccc2002",
//                                            accountID: "13555479-077f-445e-87f0-e6eae2e215c5",
//                                            screenName: "Home Screen",
//                                            position: "1")
//            }
//            .padding()
//            .background(Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(10)
//        }
//        .padding()
//    }
//}
//
//#Preview {
//    SwiftUIView()
//}
