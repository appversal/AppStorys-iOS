//
//  File.swift
//  AppStorys-iOS
//
//  Created by Darshika Gupta on 27/02/25.
//

import Foundation

struct CampaignBanner: Identifiable, Decodable {
    let id: String
    let campaignType: String  // Should be "BAN" for banners
    let details: BannerDetails
}

struct BannerDetails: Identifiable, Decodable {
    let id: String
    let image: String
    let height: Double?  // Using `Double` instead of `num` for numerical values
    let link: String?
}
