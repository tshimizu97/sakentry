//
//  AuthManager.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/16.
//

import Foundation
import Firebase
import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var established: Bool = false
    @Published var signedIn: Bool = false
    @Published var user: User
    @Published var editProfile = false
    
    private var handle: AuthStateDidChangeListenerHandle!
    
    init() {
        self.signedIn = false
        self.user = User("login failure")
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                let db = Firestore.firestore()
                let ref = db.collection("users").document(user.uid)
                ref.addSnapshotListener() { (document, err) in
                    if let err = err {
                        print("User database fetch failure: \(err.localizedDescription)")
                    } else {
                        if let document = document { // this is always the case if err is nil
                            if let data = document.data() {
                                self.user = User(user: data)
                                self.user.getImage()
                            }
                            else {
                                self.user = User(user: user)
                                self.editProfile = true
                            }
                            self.signedIn = true
                        }
                    }
                    self.established = true
                }
            } else {
                self.established = true
            }
        }
    }
    
    deinit {
        Auth.auth().removeStateDidChangeListener(handle)
    }
    
}
