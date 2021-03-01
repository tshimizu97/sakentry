//
//  AddToCellarView.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/02/01.
//

import Firebase
import SwiftUI

struct AddToCellarView: View {
    @EnvironmentObject var authManager: AuthManager
    let product: Product
    @Binding var showAddToCellarView: Bool
    
    @State var nBottles: Int
    @State var image: UIImage?
    @State var date: Date
    @State var vintage: Int
    @ObservedObject var notes: TextManager
    @State var editing: String?
    
    let dateFormatter: DateFormatter
    let bottleNumbers: [Int]
    let vintageYears: [Int]
    let maxCharCount: Int
    let placeHolder: String
    
    init(product: Product, showAddToCellarView: Binding<Bool>, image: UIImage?=nil) {
        self.product = product
        self._showAddToCellarView = showAddToCellarView
        self._nBottles = State(initialValue: 1)
        self._image = State(initialValue: image)
        let now: Date = Date()
        self._date = State(initialValue: now)
        self._vintage = State(initialValue: 0) // 0 means nil
        self.maxCharCount = 512
        self.notes = TextManager(limit: maxCharCount)
        self.placeHolder = "add_notes_here"
        self.bottleNumbers = Array(1...60)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        self.dateFormatter = dateFormatter
        let date = dateFormatter.string(from: now)
        let year: Int = Int(date.components(separatedBy: "/")[2]) ?? 2021
        self.vintageYears = Array(1950...year) + [0]
        self._editing = State(initialValue: nil)
    }
    
    func addToCellar() {
        let ref = Firestore.firestore().collection("cellar")
        var newBottle: [String: Any] = [String:Any]()
        
        let uid = self.authManager.user.uid
        newBottle["uid"] = uid
        let pid = self.product.id
        newBottle["pid"] = pid
        let now: Date = Date()
        let time = now.timeIntervalSince1970
        newBottle["time"] = time // treated as float
        newBottle["date_add"] = self.dateFormatter.string(from: self.date)
        if !self.notes.isEmpty() {
            newBottle["notes"] = self.notes.text
        }
        newBottle["drunk"] = false
        newBottle["deleted"] = false
        newBottle["vintage"] = self.vintage
        newBottle["nBottles"] = self.nBottles
        if let image = self.image { // if image is not empty
            let imageURL = "products_user/\(pid)/\(time)_\(uid).jpg"
            newBottle["imageURL"] = imageURL
            let storageRef = Storage.storage().reference().child(imageURL)
            var quality: CGFloat = 0.95 // compression quality of JPEG
            while true {
                if quality <= 0 {
                    print("ERROR: failed to upload an image - file is too big.")
                    break
                }
                if let imageData: Data = image.jpegData(compressionQuality: quality) {
                    if Int64(imageData.count) / 1024 < 100 { // file size is less than 100KB
                        _ = storageRef.putData(imageData, metadata: nil) { (metadata, err) in
                            guard let _ = metadata else {
                                print("Error in uploading a user's product photo")
                                return // return null
                            }
                        }
                    }
                }
                quality -= 0.05
            }
        }
        
        ref.addDocument(data: newBottle) { err in
            if let err = err { // if error happens
                print("Error in uploading a new review")
                print(err)
            }
            else {
                print("Successfully cellared a new bottle!")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                List {
                    // image
                    HStack {
                        Text(NSLocalizedString("picture", lang: authManager.user.language))
                        Spacer()
                        UploadImageView(self.$image, widthScale: 0.45, hToW: 1.5, geo: geo)
                    }
                    
                    // number of bottles
                    HStack {
                        Text(NSLocalizedString("bottles"))
                        Spacer()
                        Text(String(self.nBottles))
                    }
                    .onTapGesture {
                        self.editing = "nBottles"
                    }
                    if self.editing == "nBottles" {
                        Picker(selection: $nBottles, label: EmptyView()) {
                            ForEach(self.bottleNumbers, id: \.self) { n in
                                Text(String(n))
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                    }
                    
                    // date
                    HStack {
                        Text(NSLocalizedString("date", lang: authManager.user.language))
                        Spacer()
                        Text(NSLocalizedString(self.dateFormatter.string(from: self.date), lang: authManager.user.language))
                    }
                    .onTapGesture {
                        self.editing = "date"
                    }
                    if self.editing == "date" {
                        DatePicker("", selection: self.$date, displayedComponents: .date)
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .environment(\.locale, Locale(identifier: authManager.user.language ?? "en"))
                    }
                    
                    // vintage
                    HStack {
                        Text(NSLocalizedString("vintage", lang: authManager.user.language))
                        Spacer()
                        if self.vintage == 0 {
                            Text(NSLocalizedString("choose_vintage", lang: authManager.user.language))
                        }
                        else {
                            Text(String(self.vintage))
                        }
                    }
                    .onTapGesture {
                        self.editing = "vintage"
                    }
                    if self.editing == "vintage" {
                        Picker(selection: $vintage, label: EmptyView()) {
                            ForEach(self.vintageYears, id: \.self) { year in
                                if year == 0 {
                                    Text(NSLocalizedString("choose_vintage", lang: authManager.user.language))
                                }
                                else {
                                    Text(String(year))
                                }
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                    }
                    
                    // notes
                    HStack {
                        Text(NSLocalizedString("notes", lang: authManager.user.language))
                        Spacer()
                        if self.notes.text == "" {
                            Text(NSLocalizedString("add_notes", lang: authManager.user.language))
                        }
                        else {
                            Text(self.notes.text)
                        }
                    }
                    .onTapGesture {
                        self.editing = "notes"
                    }
                    if self.editing == "notes" {
                        TastingNote(self._notes, maxCharCount: self.maxCharCount, placeHolder: self.placeHolder, title: nil)
                    }
                }
                .navigationBarItems(leading: Button(action: {
                    self.showAddToCellarView.toggle()
                }) {
                    Text(NSLocalizedString("cancel", lang: authManager.user.language))
                }, trailing: Button(action: {
                    self.addToCellar()
                    self.showAddToCellarView.toggle()
                }) {
                    Text(NSLocalizedString("save", lang: authManager.user.language))
                })
            }
        }
        .navigationBarTitle("add_to_cellar")
    }
}
