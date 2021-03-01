//
//  MyProfile.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/02/06.
//

import Firebase
import FirebaseAuth
import SwiftUI

struct MyProfile: View {
    @EnvironmentObject var authManager: AuthManager
    @State var editProfile = false
    
    var body: some View {
        NavigationView {
            VStack {
                // put profile picture here, or a logo
                Text("\(self.authManager.user.displayName)")
                    .help("THIS IS MY NAME")
                HStack {
                    VStack {
                        Text("\(self.authManager.user.followers.count)")
                        Text("followers")
                    }
                    VStack {
                        Text("\(self.authManager.user.followings.count)")
                        Text("following")
                    }
                }
                .padding()
                List {
                    Group { // put the numbers in each elements
                        NavigationLink(destination: MyReviews()) {
                            Text(NSLocalizedString("my_reviews", lang: authManager.user.language))
                        }
                        NavigationLink(destination: MyCellar()) {
                            Text(NSLocalizedString("my_cellar", lang: authManager.user.language))
                        }
                        NavigationLink(destination: Bookmarked()) {
                            Text(NSLocalizedString("bookmarked", lang: authManager.user.language))
                        }
                    }
                    
                    Group {
                        Button(action: {
                            do {
                                try Auth.auth().signOut()
                            } catch {
                                print("Error")
                            }
                        }) {
                            Text("Log-Out")
                        }
                    }
                }
            }
            .navigationBarTitle(NSLocalizedString("profile", lang: authManager.user.language),
                                displayMode: .inline)
            .navigationBarItems(leading:
                // here's the icon
                Button(action: {
                    self.editProfile.toggle()
                }) {
                    Text("\u{2699}\u{0000FE0E}" as String)
                        .font(.system(size: 40))
                        .foregroundColor(.black)
                }
                .fullScreenCover(isPresented: $editProfile) {
                    if let user = authManager.user {
                        EditProfile(
                            user: user,
                            editProfile: $editProfile,
                            title: "edit_profile",
                            profileImage: authManager.user.image)
                    }
                }
            )
        }
    }
}
