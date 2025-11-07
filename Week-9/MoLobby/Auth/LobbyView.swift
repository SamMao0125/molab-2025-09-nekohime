//
// LobbyView - Tuxedo Cat Theme
// Black with white accents, gradient backgrounds
//

import SwiftUI

struct LobbyView: View {

    @EnvironmentObject var lobbyModel: LobbyModel
    @EnvironmentObject var app: AppModel
    
    @State private var showMoodPicker = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient - extends to full screen
                TuxedoColors.darkGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Tuxedo cat ears decoration at top
                    TuxedoCatEarsDecoration(size: 15, color: TuxedoColors.tuxedoBlack)
                        .padding(.top, 8)
                    
                    userHeaderView()
                    
                    TuxedoWhiskerDivider()
                    
                    if app.settings.showUsers {
                        userListView()
                    } else {
                        ScrollView {
                            AppSettingView()
                        }
                    }
                }
            }
            .navigationTitle("ฅ MeowLobby v\(app.verNum) ฅ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(TuxedoColors.tuxedoBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        app.settings.showUsers.toggle()
                        app.saveSettings()
                    }) {
                        HStack(spacing: 4) {
                            if app.settings.showUsers {
                                Text("(=^･ω･^=)")
                                    .font(.caption)
                            } else {
                                Text("(=^‥^=)")
                                    .font(.caption)
                            }
                            Image(systemName: app.settings.showUsers ?
                                  "person.3.sequence.fill" : "person.3.sequence")
                        }
                        .foregroundColor(TuxedoColors.pureWhite)
                    }
                }
            }
            .sheet(isPresented: $showMoodPicker) {
                if let currentUser = lobbyModel.currentUser {
                    MoodPickerSheet(
                        selectedMood: Binding(
                            get: { currentUser.catMood },
                            set: { _ in }
                        ),
                        onSave: { newMood in
                            lobbyModel.updateCurrentUserMood(newMood)
                        }
                    )
                }
            }
        }
        .onAppear {
            print("LobbyView onAppear ฅ(^・ω・^ฅ)")
        }
    }
    
    private func userHeaderView() -> some View {
        VStack(spacing: 12) {
            userDetailRow()
            
            HStack(spacing: 12) {
                // Change Mood Button
                Button(action: {
                    showMoodPicker = true
                }) {
                    HStack {
                        Text("ㅅ")
                        if let currentUser = lobbyModel.currentUser {
                            Text(currentUser.catMood.kaomoji)
                            Text("Change Mood")
                        }
                    }
                }
                .buttonStyle(TuxedoButtonStyle(
                    backgroundColor: TuxedoColors.charcoalBlack,
                    foregroundColor: TuxedoColors.pureWhite
                ))
                
                // Sign Out Button
                Button(action: lobbyModel.signOut) {
                    HStack {
                        Text("(=｀ω´=)")
                        Text("Sign Out")
                    }
                }
                .buttonStyle(TuxedoButtonStyle(
                    backgroundColor: TuxedoColors.huntingRed,
                    foregroundColor: TuxedoColors.pureWhite
                ))
            }
            .padding(.horizontal, 5)
        }
    }
    
    private func userDetailRow() -> some View {
        HStack {
            if let currentUser = lobbyModel.currentUser {
                NavigationLink {
                    UserDetailView(user: currentUser)
                } label: {
                    HStack(spacing: 12) {
                        // White paw print for active user
                        TuxedoPawPrintIndicator(isActive: true, size: 14)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(currentUser.name)
                                    .font(.headline)
                                    .foregroundColor(TuxedoColors.pureWhite)
                                
                                // Current mood display
                                CompactMoodDisplay(mood: currentUser.catMood, showLabel: true)
                            }
                            Text(currentUser.email)
                                .font(.subheadline)
                                .foregroundColor(TuxedoColors.silverGray)
                            if !currentUser.caption.isEmpty {
                                Text(currentUser.caption)
                                    .lineLimit(1)
                                    .font(.subheadline)
                                    .foregroundColor(TuxedoColors.whiskerSilver)
                            }
                        }
                    }
                }
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(TuxedoColors.cardGradient)
                .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
    
    private func userListView() -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                HStack {
                    Text("ฅ(^・ω・^ฅ)")
                        .font(.title3)
                        .foregroundColor(TuxedoColors.pureWhite)
                    Text("\(lobbyModel.users.count) cats in lobby")
                        .font(.headline)
                        .foregroundColor(TuxedoColors.pureWhite)
                }
                .padding(.top, 12)
                
                ForEach(lobbyModel.users) { user in
                    VStack(spacing: 0) {
                        NavigationLink {
                            UserDetailView(user: user)
                        } label: {
                            userRowView(user: user)
                        }
                        .buttonStyle(.plain)
                        
                        // Whisker divider between users
                        if user.id != lobbyModel.users.last?.id {
                            TuxedoWhiskerDivider()
                                .padding(.vertical, 8)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func userRowView(user: UserModel) -> some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                // Profile image with tuxedo border
                AsyncImage(url: URL(string: user.profileImg)) { phase in
                    switch phase {
                    case .empty:
                        LoadingCat()
                            .frame(width: 80, height: 80)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                user.catMood.tuxedoAccentColor,
                                                user.catMood.tuxedoAccentColor.opacity(0.5)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
                            .shadow(color: user.catMood.tuxedoAccentColor.opacity(0.3), radius: 8, x: 0, y: 0)
                    case .failure(_):
                        CatProfilePlaceholder(size: 80)
                    @unknown default:
                        CatProfilePlaceholder(size: 80)
                    }
                }
                
                // Active indicator - white paw print
                if user.activeCount > 0 {
                    TuxedoPawPrintIndicator(isActive: true, size: 12)
                        .offset(x: 5, y: 5)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(user.name)
                        .font(.headline)
                        .foregroundColor(TuxedoColors.pureWhite)
                    
                    // User's current mood
                    CompactMoodDisplay(mood: user.catMood, showLabel: true)
                }
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(TuxedoColors.silverGray)
                HStack {
                    Text(user.dateIn.getElapsedInterval())
                        .font(.caption)
                        .foregroundColor(TuxedoColors.smokyGray)
                    Spacer()
                    if let label = user.activeCountLabel {
                        HStack(spacing: 2) {
                            Text("ㅅ")
                                .font(.caption2)
                                .foregroundColor(TuxedoColors.whiskerSilver)
                            Text(label)
                                .font(.caption)
                                .foregroundColor(TuxedoColors.whiskerSilver)
                        }
                    }
                }
                if !user.caption.isEmpty {
                    Text(user.caption)
                        .font(.subheadline)
                        .lineLimit(1)
                        .foregroundColor(TuxedoColors.creamWhite)
                }
            }
            Spacer()
        }
        .padding()
        .tuxedoCard(mood: user.catMood)
    }
}

struct LocationRow: View {
    var user: UserModel
    
    @EnvironmentObject var lobbyModel: LobbyModel
    @EnvironmentObject var app: AppModel
    
    var body: some View {
        if let locationDescription = user.locationDescription {
            HStack {
                Text("ᓚᘏᗢ")
                    .font(.caption)
                    .foregroundColor(TuxedoColors.pureWhite)
                Text(locationDescription)
                    .foregroundColor(TuxedoColors.silverGray)
            }
        }
    }
}
