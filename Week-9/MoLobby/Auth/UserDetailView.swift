//
//  UserDetailView.swift
//  MeowLobby
//
//  Created by jht2 on 2023-02-09
//

import SwiftUI

struct UserDetailView: View {
    
    @ObservedObject var user: UserModel
    
    @EnvironmentObject var lobbyModel: LobbyModel
    @EnvironmentObject var app: AppModel
    
    @State private var showMoodPicker = false
    @State private var showTemplatePicker = false
    
    var isCurrentUser: Bool {
        user.id == lobbyModel.currentUser?.id
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Cat ears decoration
                CatEarsDecoration(size: 20, color: .orange.opacity(0.6))
                    .padding(.top, 10)
                
                // Profile image with cat placeholder fallback
                AsyncImage(url: URL(string: user.profileImg)) { phase in
                    switch phase {
                    case .empty:
                        LoadingCat()
                            .frame(width: 120, height: 120)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(user.catMood.color.opacity(0.5), lineWidth: 4)
                            )
                    case .failure(_):
                        CatProfilePlaceholder(size: 120, catType: .sitting)
                    @unknown default:
                        CatProfilePlaceholder(size: 120, catType: .sitting)
                    }
                }
                .padding(2)
                
                // User info with mood
                VStack(spacing: 8) {
                    Text(user.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(user.email)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    // Mood Display - prominent
                    VStack(spacing: 8) {
                        Text(user.catMood.kaomoji)
                            .font(.system(size: 50))
                        
                        HStack {
                            CompactMoodDisplay(mood: user.catMood, showLabel: true)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(user.catMood.backgroundColor)
                                .overlay(
                                    Capsule()
                                        .stroke(user.catMood.borderColor, lineWidth: 2)
                                )
                        )
                        
                        Text(user.catMood.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // Change mood button - only for current user
                    if isCurrentUser {
                        Button(action: {
                            showMoodPicker = true
                        }) {
                            HStack {
                                Text("ㅅ")
                                Text("Change My Mood")
                            }
                        }
                        .buttonStyle(CatButtonStyle(backgroundColor: user.catMood.color))
                    }
                    
                    // Active count with paw prints
                    if user.activeCount > 0 {
                        HStack(spacing: 8) {
                            PawPrintIndicator(isActive: true, size: 10)
                            Text("Signed in \(user.activeCount) time\(user.activeCount == 1 ? "" : "s")")
                                .font(.subheadline)
                            PawPrintIndicator(isActive: true, size: 10)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                WhiskerDivider()
                
//                if let locationDescription = user.locationDescription {
//                    Button {
////                    app.toMapTab()
//                    } label: {
//                        HStack {
//                            Text("ᓚᘏᗢ")
//                                .font(.title3)
//                            Text(locationDescription)
//                                .padding(1)
//                        }
//                    }
//                }
                
//                Button(action: {
////                let key = user.userGalleryKey
////                app.selectGallery(key: key)
//                }) {
//                    Text("Photos")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding()
//                // .frame(maxWidth: .infinity)
//                        .background(Color(.systemIndigo))
//                        .cornerRadius(12)
//                        .padding(5)
//                }
                
                // Stats section
                if let init_lapse = user.stats["init_lapse"] as? Double {
                    HStack {
                        Text("(=^･ω･^=)")
                        Text("init_lapse: " + String(format: "%.2f", init_lapse))
                            .font(.subheadline)
                    }
                }
                if let load_lapse = user.stats["load_lapse"] as? Double {
                    HStack {
                        Text("ฅ(^・ω・^ฅ)")
                        Text("load_lapse: " + String(format: "%.2f", load_lapse))
                            .font(.subheadline)
                    }
                }
                
                // Caption section - only editable for current user
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("ㅅ")
                            .font(.title3)
                        Text("Cat Caption")
                            .font(.headline)
                        
                        Spacer()
                        
                        // Template button for current user
                        if isCurrentUser {
                            Button(action: {
                                showTemplatePicker = true
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "text.bubble.fill")
                                    Text("Templates")
                                }
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(Color.orange.opacity(0.2))
                                )
                                .foregroundColor(.orange)
                            }
                        }
                    }
                    
                    if isCurrentUser {
                        // Quick templates bar
                        QuickTemplatesBar(caption: $user.caption)
                            .padding(.horizontal)
                        
                        // Text field
                        TextField("Share something... (=^‥^=)", text: $user.caption, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                            .lineLimit(3...6)
                    } else {
                        if user.caption.isEmpty {
                            Text("This cat hasn't shared anything yet (=^‥^=)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        } else {
                            Text(user.caption)
                                .font(.subheadline)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                WhiskerDivider()
                
                Spacer()
            }
        }
        .navigationTitle("ฅ Cat Profile ฅ")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showMoodPicker) {
            MoodPickerSheet(
                selectedMood: Binding(
                    get: { user.catMood },
                    set: { _ in }
                ),
                onSave: { newMood in
                    lobbyModel.updateCurrentUserMood(newMood)
                }
            )
        }
        .sheet(isPresented: $showTemplatePicker) {
            CaptionTemplatePicker(caption: $user.caption)
        }
        .onAppear {
            print("UserDetailView onAppear (=^･ω･^=)", user.catMood.rawValue)
//            lobbyModel.locsForUsers(firstLoc: user.loc)
        }
        .onDisappear {
            print("UserDetailView onDisappear (=｀ω´=)")
            if isCurrentUser {
                lobbyModel.updateUser(user: user)
            }
        }
    }
}

//struct AppSettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        AppSettingView( )
//            .environmentObject(AppModel())
//    }
//}
