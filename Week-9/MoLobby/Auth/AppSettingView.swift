//
//  AppSettingView.swift
//  MeowLobby
//
//  Created by jht2 on 12/22/22.
//

import SwiftUI

// !!@ can't get label to work for TextField
// maybe macOS issue
// https://developer.apple.com/documentation/swiftui/textfield
// !!@ fails to give label on iOS
//            TextField(text: $app.applePhotoAlbumName, prompt: Text("Required")) {
//                Text("Username")
//            }

struct AppSettingView: View {
    
    @EnvironmentObject var app: AppModel

    var body: some View {
        Form {
            Section {
                VStack(spacing: 12) {
                    // Cat ears decoration
                    CatEarsDecoration(size: 15, color: .orange.opacity(0.6))
                    
                    HStack {
                        Text("(=^･ω･^=)")
                            .font(.title2)
                        Text("Meow Settings")
                            .font(.headline)
                    }
                    
                    WhiskerDivider()
                    
                    Link(destination: URL(string: "https://github.com/mobilelabclass-itp/98-MoGallery")!) {
                        HStack {
                            Text("ฅ")
                                .font(.title3)
                            Text("MeowLobby git repo")
                            Spacer()
                            Image(systemName: "arrow.up.forward.square")
                        }
                    }
                    .padding(8)
                }
            }
//            Section {
//                Text("Firebase Storage")
//                Toggle("Add Random Warning", isOn: $app.settings.randomAddWarning)
//                Toggle("Store Camera Capture", isOn: $app.settings.storeAddEnabled)
//                Toggle("Store FullRez", isOn: $app.settings.storeFullRez)
//                HStack {
//                    Text("Photo Size")
//                        // .bold()
//                        .frame(width:160)
//                    TextField("", text: $app.settings.storePhotoSize)
//                }
//            }
//            Section {
//                Text("Apple Photos")
//                Toggle("Photos Camera Capture", isOn: $app.settings.photoAddEnabled)
//                HStack {
//                    Text("Photo Size")
//                        // .bold()
//                        .frame(width:160)
//                    TextField("", text: $app.settings.photoSize)
//                }
//                HStack {
//                    Text("Album Name")
//                        .frame(width:160)
//                    TextField("", text: $app.settings.photoAlbum)
//                }
//            }
            Section {
                HStack {
                    Text("ㅅ")
                        .font(.caption)
                    Text("Territory Settings")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .listRowSeparator(.hidden)
                
//                HStack {
//                    Text("Gallery Key")
//                        .frame(width:160)
//                    TextField("", text: $app.settings.storeGalleryKey)
//                }
                HStack {
                    Text("🐾")
                    Text("Lobby Key")
                        .frame(width:140)
                    TextField("", text: $app.settings.storeLobbyKey)
                }
                HStack {
                    Text("🐾")
                    Text("StorePrefix")
                        .frame(width:140)
                    TextField("", text: $app.settings.storePrefix)
                }
            }
            
            Section {
                HStack {
                    Spacer()
                    VStack {
                        Text("ᓚᘏᗢ")
                            .font(.system(size: 40))
                        Text("Happy Meowing!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .onDisappear {
            print("AppSettingView onDisappear (=｀ω´=)")
            app.updateSettings();
        }
    }
}

struct AppSettingView_Previews: PreviewProvider {
    static var previews: some View {
        AppSettingView( )
            .environmentObject(AppModel())
    }
}
