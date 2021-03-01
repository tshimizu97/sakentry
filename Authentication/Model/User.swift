//
//  User.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/13.
//

import Foundation
import Firebase

class User {
    let uid: String
    var lastName: String
    var firstName: String
    var displayName: String
    var gender: String
    var birthdate: String
    var email: String
    var phoneNumber: String // optional for now
    var language: String
    var country: String
    var region: String // optional if country is not us/ja
    var bio: String // optional
    var followers: [String]
    var followings: [String]
    var imageURL: String // optional
    var image: UIImage?
    var deleted: Bool
    
    func getImage(){
        if self.imageURL != "" {
            let storage = Storage.storage()
            let storageRef = storage.reference(withPath: self.imageURL)
            storageRef.getData(maxSize: 1 * 1024 * 1024) { data, err in
                if let err = err {
                    print("Something went wrong in getting profile image: \(err)")
                } else {
                    if let data = data {
                        self.image = UIImage(data: data)
                        /*do {
                            // change path to the proper path to cache so: add cache path before self.imageURL
                            try data.write(to: URL(fileURLWithPath: self.imageURL))
                        }
                        catch {
                            print("ERROR: failed to save a product image in cache.")
                            print(error)
                        }*/
                    }
                }
            }
        }
    }
    
    // first log-in
    init(user: FirebaseAuth.User) {
        self.uid = user.uid
        self.firstName = ""
        self.lastName = ""
        self.displayName = user.displayName ?? ""
        self.email = user.email ?? "" // if email is not available that is a bit of problem?
        self.phoneNumber = user.phoneNumber ?? ""
        let local_lang = NSLocalizedString("lang_code", comment: "")
        if ["en", "ja"].contains(local_lang) {
            self.language = local_lang
        }
        else {
            self.language = "en"
        }
        self.gender = ""
        let formatter: DateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MM/yyyy"
        self.birthdate = formatter.string(from: Date())
        self.country = ""
        self.region = ""
        self.bio = ""
        self.followers = []
        self.followings = []
        self.imageURL = ""
        self.deleted = false
    }
    
    // normal log-in
    init(user: [String:Any]) {
        self.uid = user["uid"] as! String
        self.firstName = user["firstName"] as! String
        self.lastName = user["lastName"] as! String
        self.displayName = user["displayName"] as! String
        self.email = user["email"] as? String ?? ""
        self.phoneNumber = user["phoneNumber"] as? String ?? ""
        self.language = user["language"] as! String
        self.gender = user["gender"] as? String ?? ""
        self.birthdate = user["birthdate"] as? String ?? ""
        self.country = user["country"] as! String
        self.region = user["region"] as? String ?? ""
        self.bio = user["bio"] as? String ?? ""
        self.followers = user["followers"] as? [String] ?? []
        self.followings = user["followings"] as? [String] ?? []
        self.imageURL = user["imageURL"] as? String ?? ""
        self.deleted = user["deleted"] as? Bool ?? false
    }
    
    init(_ unknown: String) {
        self.uid = ""
        self.firstName = ""
        self.lastName = ""
        self.displayName = ""
        self.email = ""
        self.phoneNumber = ""
        self.language = "en"
        self.gender = ""
        self.birthdate = ""
        self.country = ""
        self.region = ""
        self.bio = ""
        self.followers = []
        self.followings = []
        self.imageURL = ""
        self.deleted = false
    }
    
    func toDict() -> [String:Any] {
        let mirror = Mirror(reflecting: self)
        var dict = [String:Any]()
        
        for (key, valueAny) in mirror.children {
            if let key = key {
                if let value = valueAny as? String {
                    if value != "" {
                        dict[key] = value
                    }
                }
                if let value = valueAny as? [String] {
                    dict[key] = value
                }
            }
        }
        return dict
    }
}
