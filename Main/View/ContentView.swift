//
//  ContentView.swift
//  Shared
//
//  Created by Takao Shimizu on 2021/01/05.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @State var selection = 0
    
    var body: some View {
        if authManager.established {
            if authManager.signedIn { // if signed in
                // if user exists {
                TabView(selection: $selection) {
                    SearchPage()
                        .tabItem {
                            VStack {
                                Image(systemName: "magnifyingglass")
                                Text(NSLocalizedString("search", lang: authManager.user.language))
                            }
                        }
                        .tag(1)
                    
                    Text("HERE IS SCAN OPTION")
                        .tabItem {
                            VStack {
                                Image(systemName: "camera")
                                Text(NSLocalizedString("camera", lang: authManager.user.language))
                            }
                        }
                        .tag(2)
                    
                    MyProfile()
                        .tabItem {
                            VStack {
                                Image(systemName: "person")
                                Text(NSLocalizedString("profile", lang: authManager.user.language))
                            }
                        }
                        .tag(3)
                }
                .fullScreenCover(isPresented: $authManager.editProfile) {
                    if let user: User = authManager.user {
                        EditProfile(
                            user: user,
                            editProfile: $authManager.editProfile,
                            title: NSLocalizedString("create profile", lang: authManager.user.language),
                            profileImage: self.authManager.user.image)
                    }
                }
            }
            else { //if not signed in
                AuthUIView()
            }
        }
        else {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                }
                Spacer()
            }
        }
    }
}
