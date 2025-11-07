//
//  LoginView.swift - Tuxedo Theme
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var lobbyModel: LobbyModel
    @EnvironmentObject var app: AppModel
    @Environment(\.openURL) var openURL

    var body: some View {
        NavigationStack {
            ZStack {
                // Elegant dark gradient background
                TuxedoColors.darkGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Spacer(minLength: 80)
                        
                        // Tuxedo cat ears decoration - black
                        TuxedoCatEarsDecoration(size: 35, color: TuxedoColors.tuxedoBlack)
                            .padding(.bottom, 20)
                        
                        // App name with white gradient
                        Text("MeowLobby")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [TuxedoColors.pureWhite, TuxedoColors.creamWhite],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: TuxedoColors.pureWhite.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        // Tuxedo cat face kaomoji with glow
                        ZStack {
                            // Glow effect
                            Text("(=^・ω・^=)")
                                .font(.system(size: 70))
                                .foregroundColor(TuxedoColors.pureWhite)
                                .blur(radius: 20)
                                .opacity(0.6)
                            
                            // Main kaomoji
                            Text("(=^・ω・^=)")
                                .font(.system(size: 70))
                                .foregroundColor(TuxedoColors.pureWhite)
                        }
                        .padding(.vertical, 20)
                        
                        // Welcome text
                        VStack(spacing: 10) {
                            Text("Welcome to MeowLobby")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(TuxedoColors.pureWhite)
                            
                            Text("version \(app.verNum)")
                                .font(.subheadline)
                                .foregroundColor(TuxedoColors.silverGray)
                        }
                        
                        // White whisker divider
                        TuxedoWhiskerDivider(color: TuxedoColors.whiskerSilver)
                            .padding(.vertical, 10)
                        
                        // Description with white text
                        VStack(spacing: 12) {
                            Text("Purr-fect place to meet fellow cats!")
                                .font(.body)
                                .foregroundColor(TuxedoColors.creamWhite)
                            
                            Text("ฅ(^・ω・^ฅ)")
                                .font(.title2)
                                .foregroundColor(TuxedoColors.pureWhite)
                            
                            Text("Sign in to join the clowder")
                                .font(.subheadline)
                                .foregroundColor(TuxedoColors.silverGray)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)
                        
                        // Google Sign In Button with white background
                        Button(action: {
                            lobbyModel.signIn()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                                
                                Text("Sign in with Google")
                                    .font(.headline)
                            }
                            .foregroundColor(TuxedoColors.tuxedoBlack)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(TuxedoColors.whiteGradient)
                                    .shadow(color: TuxedoColors.pureWhite.opacity(0.4), radius: 12, x: 0, y: 6)
                            )
                        }
                        .padding(.horizontal, 40)
                        
                        Spacer(minLength: 60)
                        
                        // Footer with white paw prints
                        VStack(spacing: 16) {
                            HStack(spacing: 15) {
                                TuxedoPawPrintIndicator(isActive: true, size: 10)
                                Text("Join the meow-ment")
                                    .font(.caption)
                                    .foregroundColor(TuxedoColors.whiskerSilver)
                                TuxedoPawPrintIndicator(isActive: true, size: 10)
                            }
                            
                            // Small gold collar accent
                            Rectangle()
                                .fill(TuxedoColors.goldGradient)
                                .frame(width: 60, height: 4)
                                .cornerRadius(2)
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .onAppear {
            print("LoginView onAppear (=^･ω･^=) currentUser", lobbyModel.currentUser?.email ?? "-none-")
        }
        .onDisappear {
            print("LoginView onDisappear (=｀ω´=)")
            app.locationManager.requestUse()
        }
    }
}
