//
//  SwiftUIView.swift
//  AppStorys-iOS
//
//  Created by Darshika Gupta on 27/02/25.

import SwiftUI

@MainActor
final class CampaignViewModel: ObservableObject {
    
    @Published var campaigns: [Campaign] = []
    private let apiService: APIService
    private let appID: String
    private let accountID: String
    private let screenName: String

    init(appID: String, accountID: String, screenName: String) {
        self.appID = appID
        self.accountID = accountID
        self.screenName = screenName
        self.apiService = APIService()
    }

    func fetchCampaigns() {
         Task {
             do {
                 let validatedAccount = try await apiService.validateAccount(appID: appID, accountID: accountID)
                 guard validatedAccount else {
                     print("Account validation failed.")
                     return
                 }
                 print("Account validated successfully.")

                 let campaignList = try await apiService.getCampaignList(forScreen: screenName)
                 print("Fetched campaign list: \(campaignList)")

                 let fetchedCampaigns = try await apiService.getCampaigns(campaignList: campaignList)
                 print("Fetched campaigns: \(fetchedCampaigns)")

                 await MainActor.run {
                     self.campaigns = fetchedCampaigns
                     print("Updated campaigns: \(self.campaigns)")
                 }
             } catch {
                 print("Error fetching campaigns: \(error)")
             }
         }
     }

}
