//
//  FullScreenPipView.swift
//  AppStorys-iOS
//
//  Created by Darshika Gupta on 02/03/25.
//


import SwiftUI
import AVKit

public struct FullScreenPipView : View {
    
    @State private var isMuted = false
    @State private var position = CGSize.zero
    @StateObject private var playerManager = AVPlayerManager()
    @Binding var isVisible: Bool
    @StateObject private var apiService = APIServiceTwo()
    
    let appID: String
    let accountID: String
    let screenName: String
    let positionID: String
    
    public init(appID: String, accountID: String, screenName: String, position: String,isVisible: Binding<Bool>) {
        self.appID = appID
        self.accountID = accountID
        self.screenName = screenName
        self.positionID = position
        self._isVisible = isVisible
       
    }
    
    var pipCampaign: PipCampaign? {
        apiService.pipCampaigns.first
    }

    public var body: some View {
        if let campaign = pipCampaign, let videoURL = campaign.details?.first?.smallVideo {
            let videoWidth = CGFloat(campaign.details?.first?.width ?? 230)
            let videoHeight = CGFloat(campaign.details?.first?.height ?? 405)
            
            ZStack {
                CustomAVPlayerView(player: playerManager.player)
                    .frame(width:  UIScreen.main.bounds.width ,
                           height: UIScreen.main.bounds.height )
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .offset(x:  0 , y:  0 )
                    .onAppear {
                        playerManager.updateVideoURL(videoURL)
                        playerManager.play()
                        trackAction(campaignID: campaign.id, actionType: .view)
                    }
                    .onTapGesture {
                        if let linkString = campaign.details?.first?.link, let link = URL(string: linkString), UIApplication.shared.canOpenURL(link) {
                            trackAction(campaignID: campaign.id, actionType: .click)
                            UIApplication.shared.open(link)
                        } else {
                            print("Invalid URL or cannot open URL")
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
                
                VStack (alignment:.leading){
                    HStack {
                        Button(action: {
                            isMuted.toggle()
                            playerManager.player.isMuted = isMuted
                        }) {
                            Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20 )
                                .padding(10 )
                        }
                        .frame(width:40 , height: 40 )
                        .background(Color.black)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .padding(.leading, 10)
                        .padding(.top, -5 )
                        
                        Spacer()
                        
                        Button(action: {
                           
                        }) {
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20 , height: 20 )
                                .padding(10 )
                        }
                        
                        .frame(width:  40 , height: 40 )
                        .background(Color.black)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .padding(.trailing, 10 )
                        .padding(.top,  -5 )
                    }
                    .frame(alignment: .top)
                    
                }
                .padding(.bottom, UIScreen.main.bounds.height - 50)
                .frame(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height )
                .offset(x:  0, y: 0)
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {  isVisible = true}) {
                            Image(systemName: "rectangle.expand.vertical")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .padding(10)
                                .foregroundStyle(Color.white)
                                .background(Color.black)
                                .clipShape(Circle())
                        }
                        .frame(width: 40, height: 40)
                                                .background(Color.black)
                                                .foregroundColor(.white)
                                                .clipShape(Circle())
                                                .padding(.trailing,10)
                                                .padding(.bottom, 25)
                    }
                }
                .padding(.top, UIScreen.main.bounds.height - 120 )
                .offset(x: 0, y:0)
                .frame(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height )
                
                VStack {
                    Spacer()
                    
                    if let linkString = campaign.details?.first?.link, let link = URL(string: linkString) {
                        Button(action: {
                            trackAction(campaignID: campaign.id, actionType: .click)
                            UIApplication.shared.open(link)
                            
                        }) {
                            Text("Click")
                                .font(.headline)
                                .frame(width: 180)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 50)
                    }
                }
                .frame(width: UIScreen.main.bounds.width ,
                       height: UIScreen.main.bounds.height)

            }
            .onAppear {
                apiService.validateAccount(appID: appID, accountID: accountID, screenName: screenName, position: positionID)
            }
            .frame(width: UIScreen.main.bounds.width ,
                   height: UIScreen.main.bounds.height)
            .transition(.move(edge: .trailing))
           // .animation(.easeInOut, value: isVisible)
        } else {
            ProgressView("Loading...")
                .padding()
                .onAppear {
                    apiService.validateAccount(appID: appID, accountID: accountID, screenName: screenName, position: positionID)
                }
        }
    }
    
    func trackAction(campaignID: String, actionType: ActionType) {
        guard let accessToken = apiService.accessToken else {
            print("Access Token is missing.")
            return
        }
        Task {
            do {
                print("Action tracked: \(actionType.rawValue) for campaign \(campaignID)")
            } catch {
                print("Error tracking action: \(error)")
            }
        }
    }
    
}

#Preview {
    FullScreenPipView(
        appID: "afadf960-3975-4ba2-933b-fac71ccc2002",
        accountID: "13555479-077f-445e-87f0-e6eae2e215c5",
        screenName: "Home Screen",
        position: "1",
        isVisible: .constant(false)
    )
}
