//
//  EditProfile.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/09.
//
//  Edit user profile page
//  Implementation not completed

import SwiftUI
import Firebase
import Foundation

let countries = ["JP", "US"]

struct EditProfile: View {
    @EnvironmentObject var authManager: AuthManager
    @State var image: UIImage?
    @Binding var editProfile: Bool
    let title: String
    let uid: String
    
    let fields: [String]
    @State var fieldValues: [String]
    @State var birthdate: Date
    @State var editing: String = ""
    var formatter: DateFormatter
    let langIndex: Int
    
    init(user: User, editProfile: Binding<Bool>, title: String, profileImage: UIImage?) {
        self._image = State(initialValue: profileImage)
        self.uid = user.uid
        self._editProfile = editProfile
        self.title = title
        
        let fields: [String] = [
            "firstName", "lastName", "displayName", "gender", "country", "region",
            "language", "bio" // keep everything before "country" mandatory // copy this to EditField.swift
        ]
        self.fields = fields
        var fieldValues: [String] = []
        fieldValues.append(user.firstName)
        fieldValues.append(user.lastName)
        fieldValues.append(user.displayName)
        fieldValues.append(user.gender)
        self.formatter = DateFormatter()
        self.formatter.locale = Locale(identifier: "en_US_POSIX")
        self.formatter.dateFormat = "dd/MM/yyyy"
        self._birthdate = State(initialValue: self.formatter.date(from: user.birthdate) ?? Date())
        fieldValues.append(user.country)
        fieldValues.append(user.region)
        fieldValues.append(user.language)
        fieldValues.append(user.bio)
        self._fieldValues = State(initialValue: fieldValues)
        
        self.langIndex = fields.firstIndex(where: { $0 == "language" }) ?? fields.count - 2
    }
    
    func isDisabled() -> Bool {
        if self.formatter.string(from: self.birthdate) == self.formatter.string(from: Date()) {
            return true
        }
        let countryIdx: Int = fields.firstIndex(where: { $0 == "country" }) ?? fields.count - 4
        if self.fieldValues[0..<countryIdx + 1].filter({ $0 == "" }).count == 0{
            if countries.contains(self.fieldValues[countryIdx]) {
                if self.fieldValues[countryIdx + 1] != "" {
                    return false
                }
                else {
                    return true
                }
            }
            else {
                return false
            }
        }
        else {
            return true
        }
    }
    
    func setProfileImageLocally() {
        self.authManager.user.image = self.image
    }
    
    func pushUserData() {
        let ref = Firestore.firestore().collection("users")
        var newUser: [String:Any] = self.authManager.user.toDict()
        
        newUser["birthdate"] = self.formatter.string(from: self.birthdate)
        
        for i in 0..<self.fields.count {
            let value: String  = self.fieldValues[i]
            if value != "" {
                newUser[self.fields[i]] = self.fieldValues[i]
            } else {
                newUser[self.fields[i]] = FieldValue.delete()
            }
        }
        
        if let image: UIImage = self.image {
            self.setProfileImageLocally()
            let imageURL = "profiles/\(self.authManager.user.uid).jpg"
            let storageRef = Storage.storage().reference().child(imageURL)
            var quality: CGFloat = 0.95
            while true {
                if quality <= 0 {
                    print("ERROR: failed to upload an image - file is too big.")
                    break
                }
                if let imageData: Data = image.jpegData(compressionQuality: quality) {
                    if Int64(imageData.count) / 1024 < 100 { // file size is less than 100KB
                        _ = storageRef.putData(imageData, metadata: nil) { (metadata, err) in
                            guard let _ = metadata else {
                                print("Error in uploading a user's profile photo: \(err)")
                                return // return null
                            }
                            newUser["imageURL"] = imageURL
                            newUser["lastUpdate"] = Date().timeIntervalSince1970
                            ref.document(uid).setData(newUser, merge: true) { err in
                                if let err = err {
                                    print("Error: \(err)")
                                }
                            }
                        }
                        break
                    }
                }
                quality -= 0.05
            }
        } else {
            newUser["imageURL"] = FieldValue.delete()
            ref.document(uid).setData(newUser, merge: true) { err in
                if let err = err {
                    print("Error: \(err)")
                }
            }
        }
    }
    
    func getImage() -> Image {
        if let image: UIImage = self.authManager.user.image {
            return Image(uiImage: image)
        }
        else {
            return Image(systemName: "photo")
        }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                List {
                    HStack {
                        Text(NSLocalizedString("profile_image", lang: self.fieldValues[self.langIndex]))
                        Spacer()
                        UploadImageView(self.$image, widthScale: 0.1666, hToW: 1, geo: geo)
                    }
                    HStack {
                        Text(NSLocalizedString("birthdate", lang: self.fieldValues[self.langIndex]))
                        Spacer()
                        if self.formatter.string(from: self.birthdate) == formatter.string(from: Date()) {
                            Text(NSLocalizedString("required", lang: self.fieldValues[self.langIndex]))
                                .foregroundColor(.gray)
                        } else {
                            Text(NSLocalizedString(self.formatter.string(from: self.birthdate), lang: self.fieldValues[self.langIndex]))
                        }
                    }
                    .onTapGesture {
                        self.editing = "date"
                    }
                    if self.editing == "date" {
                        DatePicker("", selection: self.$birthdate, displayedComponents: .date)
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .environment(\.locale, Locale(identifier: self.fieldValues[self.langIndex]))
                    }
                    ForEach(0..<self.fields.count) { i in
                        if self.fields[i] != "region" || countries.contains(self.fieldValues[i-1]) {
                            NavigationLink(destination: EditField(fieldIndex: i, fieldValues: self.$fieldValues)) {
                                HStack {
                                    Text(NSLocalizedString(self.fields[i], lang: self.fieldValues[self.langIndex]))
                                    Spacer()
                                    if self.fieldValues[i] != "" {
                                        if self.fields[i] == "country" {
                                            Text(NSLocale(localeIdentifier: self.fieldValues[self.langIndex])
                                                .displayName(forKey: NSLocale.Key.countryCode, value: self.fieldValues[i]) ?? self.fieldValues[i])
                                        } else if self.fields[i] == "region" || self.fields[i] == "language" {
                                            Text(NSLocalizedString(self.fieldValues[i], lang: self.fieldValues[self.langIndex]))
                                        } else {
                                            Text(self.fieldValues[i])
                                        }
                                    }
                                    else {
                                        if self.fields[i] != "bio" {
                                            Text(NSLocalizedString("required", lang: self.fieldValues[self.langIndex]))
                                                .foregroundColor(.gray)
                                        } else {
                                            Text(NSLocalizedString("optional", lang: self.fieldValues[self.langIndex]))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .navigationBarTitle(NSLocalizedString(self.title, lang: self.fieldValues[self.langIndex]), displayMode: .inline)
                .navigationBarItems(/*leading: Button(action: {
                    self.editProfile.toggle()
                }) {
                    Text(NSLocalizedString("cancel", lang: self.fieldValues[self.langIndex]))
                },*/
                trailing: Button(action: {
                    self.pushUserData()
                    self.editProfile.toggle()
                }, label: {
                    Text(NSLocalizedString("save", lang: self.fieldValues[self.langIndex]))
                }).disabled(isDisabled()))
            }
        }
    }
}
