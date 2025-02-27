import Foundation

struct Campaign: Codable {
    let id: String
    let campaignType: String
    let details: CampaignDetailsWrapper

    enum CodingKeys: String, CodingKey {
        case id
        case campaignType = "campaign_type"
        case details
    }
}
