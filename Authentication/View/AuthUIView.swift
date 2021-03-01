//
//  AuthUIView.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/08.
//

import SwiftUI
import Firebase
import FirebaseUI

struct AuthUIView: UIViewControllerRepresentable {
    class Coordinator: NSObject, FUIAuthDelegate {
        var authUIView: AuthUIView
        
        init(_ authUIView: AuthUIView) {
            self.authUIView = authUIView
        }
        
        // authUI deeals with the result of user's sign-in request
        private func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
            if let err = error {
                print("Authentication failure: \(err.localizedDescription)")
            }
            if let usr = user { // successful log in
                print("Authentication suceeded (user: \(usr)")
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let authUI =  FUIAuth.defaultAuthUI()!
        authUI.delegate = context.coordinator
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth()
        ]
        authUI.providers = providers

        return authUI.authViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // do nothing
    }
    
}
