//
//  SwiftUIView.swift
//  AppStorys-iOS
//
//  Created by Darshika Gupta on 27/02/25.
//

import SwiftUI

struct FeedbackView: View {
    @State private var rating: Int = 0
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 10) {
            // Close Button
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .padding(10)
                }
            }
            
            // Title
            Text("Hey Saarthak, how's your experience so far?")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            // Subtitle
            Text("Your feedback makes me better. Rate your experience below 👇")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Star Rating
            HStack(spacing: 10) {
                ForEach(1..<6) { index in
                    Image(systemName: rating >= index ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(rating >= index ? .yellow : .gray)
                        .onTapGesture {
                            rating = index
                        }
                }
            }
            .padding(.vertical, 10)

            // Rate Us! Button
            Button(action: {
                print("Rated \(rating) stars")
            }) {
                Text("Rate Us!")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
            }
            .padding(.top, 5)
            
        }
        .padding()
        .frame(width: 320)
        .background(Color(UIColor.systemMint).opacity(0.2))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal, 20)
    }
}

#Preview {
    FeedbackView()
}
