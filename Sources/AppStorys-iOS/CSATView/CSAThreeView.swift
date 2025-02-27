//
//  SwiftUIView.swift
//  AppStorys-iOS
//
//  Created by Darshika Gupta on 27/02/25.
//

import SwiftUI

// MARK: - CSAT Details Model
struct CsatDetails {
    let id: String
    let title: String
    let height: CGFloat?
    let width: CGFloat?
    let styling: [String: String]
    let thankyouImage: String?
    let thankyouText: String
    let thankyouDescription: String
    let descriptionText: String
    let feedbackOptions: [String: String] // Feedback options as [optionKey: displayText]
    let campaign: String
}

// MARK: - CSAT Campaign Model
struct CampaignCsat {
    let id: String
    let campaignType: String
    let details: CsatDetails
}

// MARK: - CSAT View
struct CsatView: View {
    let userId: String
    let currentCsat: CampaignCsat?
    
    @State private var showCSAT: Bool = true
    @State private var selectedStars: Int = 0
    @State private var showThanks: Bool = false
    @State private var showFeedback: Bool = false
    @State private var selectedOption: String?
    @State private var csatLoaded: Bool = false
    @State private var additionalComments: String = ""

    var body: some View {
        if !showCSAT || currentCsat == nil || csatLoaded {
            EmptyView()
        } else {
            VStack {
                Spacer() // Pushes content to the bottom
                
                VStack {
                    if showThanks {
                        thanksView()
                    } else {
                        surveyView()
                    }
                }
                .padding()
                .background(hexToColor(currentCsat!.details.styling["csatBackgroundColor"] ?? "#e8fcf7"))
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom) // Ensure it stays at the bottom
            .onAppear {
                scheduleCsatDisplay()
            }
        }
    }

    
    // MARK: - Survey View
    @ViewBuilder
    private func surveyView() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(currentCsat!.details.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(hexToColor(currentCsat!.details.styling["csatTitleColor"] ?? "#000000"))
            
            Text(currentCsat!.details.descriptionText)
                .foregroundColor(hexToColor(currentCsat!.details.styling["csatDescriptionTextColor"] ?? "#666666"))
            
            // Star Rating
            HStack {
                ForEach(1..<6) { index in
                    Image(systemName: index <= selectedStars ? "star.fill" : "star.fill")
                        .foregroundColor(index <= selectedStars ? .yellow : .gray)
                        .font(.title)
                        .onTapGesture {
                            selectedStars = index
                            showFeedback = index < 4 // Show feedback options if rating is less than 4
                            
                            if index >= 4 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    showThanks = true
                                }
                            }
                        }
                }
            }
            
            // Feedback Options
            if showFeedback {
                Text("Please tell us what went wrong?")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.top, 10)
                    
                    ForEach(currentCsat!.details.feedbackOptions.keys.sorted(), id: \.self) { key in
                        Button(action: {
                            selectedOption = key
                        }) {
                            ZStack {
                                // Background color with border
                                RoundedRectangle(cornerRadius: 50)
                                    .fill(hexToColor(selectedOption == key ? currentCsat!.details.styling["csatCtaBackgroundColor"] ?? "#01c198"
                                                                           : currentCsat!.details.styling["csatBackgroundColor"] ?? "#e8fcf7"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 50)
                                            .stroke(selectedOption == key ? Color.clear : Color.gray, lineWidth: 1) // Apply border
                                    )
                                
                                // Text with dynamic color
                                Text(currentCsat!.details.feedbackOptions[key] ?? key)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading) // Align text to leading
                                    .foregroundColor(selectedOption == key ? .white : hexToColor(currentCsat!.details.styling["csatDescriptionTextColor"] ?? "#666666")) // White if selected
                            }
                        }
                    }
                
                // Additional Comments
                TextField("Additional comments", text: $additionalComments)
                    .padding(.vertical, 8) // Add some padding for spacing
                    .background(Color.clear) // Ensure background is clear
                    .overlay(
                        Rectangle()
                            .frame(height: 1) // Underline height
                            .foregroundColor(.gray), // Underline color
                        alignment: .bottom // Position underline at the bottom
                    )
                    .padding(.top, 10) // Keep top padding

                
                // Submit Button
                HStack {
                    Button(action: {
                        showCSAT = false
                        UserDefaults.standard.setValue(true, forKey: "csat_loaded")
                    }) {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(hexToColor(currentCsat!.details.styling["csatCtaTextColor"] ?? "#FFFFFF"))
                            .frame(width: 100, height: 50)
                            .background(hexToColor(currentCsat!.details.styling["csatCtaBackgroundColor"] ?? "#01c198"))
                            .cornerRadius(25)
                    }
                }
                .frame(maxWidth: .infinity) // Ensures the button is centered
                .padding(.top, 10) // Add spacing from the previous elements

            }
        }
    }
    
    // MARK: - Thanks View
    @ViewBuilder
    private func thanksView() -> some View {
        VStack(spacing: 8) {
            if let imageUrlString = currentCsat?.details.thankyouImage,
               let imageUrl = URL(string: imageUrlString) {
                AsyncImage(url: imageUrl) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(height: 66)
                } placeholder: {
                    ProgressView()
                }
            } else {
                Text("No Image Available")
            }

            Text(currentCsat!.details.thankyouText)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color.black)
            
            Text(currentCsat!.details.thankyouDescription)
                .foregroundColor(Color.gray)
            
            Button(action: {
                showCSAT = false
                UserDefaults.standard.setValue(true, forKey: "csat_loaded")
            }) {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(hexToColor(currentCsat!.details.styling["csatCtaTextColor"] ?? "#FFFFFF"))
                    .frame(width: 100, height: 50)
                    .background(hexToColor(currentCsat!.details.styling["csatCtaBackgroundColor"] ?? "#01c198"))
                    .cornerRadius(25)
            }
        }.frame(maxWidth: .infinity)
    }
    
    // MARK: - Submit Feedback
    private func submitFeedback() {
        print("Feedback submitted:")
        print("Stars: \(selectedStars)")
        print("Selected Option: \(selectedOption ?? "None")")
        print("Additional Comments: \(additionalComments)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            showThanks = true
        }
    }
    
    // MARK: - CSAT Delay Logic
    private func scheduleCsatDisplay() {
        let delay = Int(currentCsat?.details.styling["delayDisplay"] ?? "0") ?? 0
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) {
            if !csatLoaded {
                showCSAT = true
            }
        }
    }
    
    // MARK: - Color Conversion
    private func hexToColor(_ hex: String) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        return Color(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}

// MARK: - Preview
// MARK: - Preview
struct CsatView_Previews: PreviewProvider {
    static var previews: some View {
        CsatView(userId: "afadf960-3975-4ba2-933b-fac71ccc2002", currentCsat: CampaignCsat(
            id: "csat-001",
            campaignType: "CSAT",
            details: CsatDetails(
                id: "details-001",
                title: "Hey Saarthak, how's your experience so far?",
                height: nil,
                width: nil,
                styling: [
                    "csatBackgroundColor": "#e8fcf7",
                    "csatTitleColor": "#333333",
                    "csatDescriptionTextColor": "#666666",
                    "csatCtaBackgroundColor": "#01c198",
                    "csatCtaTextColor": "#FFFFFF"
                ],
                thankyouImage: "https://emojiisland.com/cdn/shop/products/Emoji_Icon_-_Smiling_large.png?v=1571606089",
                thankyouText: "Thank You!",
                thankyouDescription: "Your feedback helps us improve!",
                descriptionText: "Your feedback makes me better. Rate your experience below 👇",
                feedbackOptions: [
                    "slowResponse": "Slow Response",
                    "unhelpfulSupport": "Unhelpful Support",
                    "difficultNavigation": "Difficult Navigation",
                    "greatExperience": "Great Experience",
                    "fastAndEfficient": "Fast and Efficient"
                ],
                campaign: "CSAT Campaign"
            )
        ))
        .onAppear {
            print("Preview Loaded") // Debugging
        }
    }
}
