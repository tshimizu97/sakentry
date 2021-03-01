//
//  SakentryApp.swift
//  Shared
//
//  Created by Takao Shimizu on 2021/01/05.
//
//  Main

import Firebase
import FirebaseUI
import SwiftUI
import UIKit

// firebase setup based on: https://github.com/firebase/firebase-ios-sdk/issues/6575
class AppDelegate: NSObject, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Firebase configuration
        FirebaseApp.configure()
        
        // navigation bar color global setting
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        let navy: UIColor = UIColor(displayP3Red: 0, green: 0.35546875, blue: 0.59375, alpha: 1)
        appearance.backgroundColor = navy

        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white
        ]
        //appearance.largeTitleTextAttributes = attrs
        appearance.titleTextAttributes = attrs

        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        
        let tabAppearance = UITabBar.appearance()
        //tabAppearance.isOpaque = false
        //tabAppearance.barTintColor = navy
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
      if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
        return true
      }
      // other URL handling goes here.
      return false
    }
}

@main
struct SakentryApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AuthManager())
        }
    }
}

// first step is make an app that can search for a product from a list, and
// checked detailed info in a new page
// -- free word partial match
// -- filtering based on parameters

// second step is make client-server communication possible
// -- use firebase to log users in the system
// -- store and retrieve user specific data: let's just start just with rating (discrete)
    // -- this user specific data is one dataframe, a row of which is one review
// -- display user specific data
// -- let users to add a new product/sake brewery

// third step is to enable for a user to rate and comment on a product
// -- free description
// -- detailed rating
// -- each review is independent from a product (there can be multiple reviews on a product)
