//
//  AddReview.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2/14/21.
//

import Firebase
import SwiftUI

struct AddReview: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var writeReview: Bool
    let pid: String
    let vintage: Int?
    
    @State var image: UIImage?
    @State var backLabel: UIImage?
    @State var rating: Double = 0
    
    let tasteValueMax: Double = 16
    @State var tasteValues: [Double] = [8, 8, 8, 8, 8, 8]
    @State var valueDisabled: [Bool] = [true, true, true, true, true, true]
    
    let maxCharCount: Int
    @ObservedObject var tastingNote: TextManager
    
    let taste_characteristics: [[String]] = [
        ["light", "bold", "body"],
        ["clean", "rich", "umami"],
        ["dry", "sweet", "sweetness"],
        ["soft", "acidic", "acidity"],
        ["smooth", "bitter", "bitterness"],
        ["watery", "thick", "mouthfeel"]
    ]
    let placeHolder: String = "write about flavours, colours, length of finish, quality-price ratio, etc."
    
    let temperatures: [String] = [
        "5_celusius", "10_celusius", "15_celusius", "30_celusius", "35_celusius", "40_celusius",
        "45_celusius", "50_celusius", "55_celusius"
    ]
    @State var temperatureBools: [Bool] = [
        false, false, false, false, false, false, false, false, false
    ]
    
    init(writeReview: Binding<Bool>, pid: String, vintage: Int?) {
        self._writeReview = writeReview
        self.pid = pid
        self.vintage = vintage
        let maxCharCount: Int = 512
        self.maxCharCount = maxCharCount
        self.tastingNote = TextManager(limit: maxCharCount)
    }
    
    func uploadImage(_ image: UIImage?, url: String?, onCompletion: () -> Void = {}) {
        if let image = image {
            if let url = url {
                let storageRef = Storage.storage().reference().child(url)
                var quality: CGFloat = 0.95 // compression quality of JPEG
                while true {
                    if quality <= 0 {
                        print("ERROR: failed to upload an image - file is too big.")
                        // should remove imageURL field from the data in collection
                        break
                    }
                    if let imageData: Data = image.jpegData(compressionQuality: quality) {
                        if Int64(imageData.count) / 1024 < 100 { // file size is less than 100KB
                            _ = storageRef.putData(imageData, metadata: nil) { (metadata, err) in
                                guard let _ = metadata else {
                                    print("Error in uploading a user's product photo")
                                    // should remove imageURL field from the data in collection
                                    return // return null
                                }
                            }
                            break
                        }
                    }
                    quality -= 0.05
                }
            }
        }
        onCompletion()
    }
    
    func saveReview() {
        let ref = Firestore.firestore().collection("reviews")
        var newReview: [String: Any] = [String:Any]()
        let uid = self.authManager.user.uid
        newReview["uid"] = uid
        newReview["userName"] = self.authManager.user.displayName
        newReview["language"] = self.authManager.user.language
        let now: Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        newReview["date"] = dateFormatter.string(from: now)
        let time: TimeInterval = now.timeIntervalSince1970  // Int
        newReview["time"] = time
        newReview["pid"] = self.pid
        newReview["vintage"] = vintage
        newReview["likeUid"] = []
        newReview["likeCount"] = 0
        newReview["commentCount"] = 0
        // comment should be added as subcollection whose elements are uid, time, and text
        
        newReview["rating"] = self.rating
        for (i, isDisabled) in self.valueDisabled.enumerated() {
            if isDisabled == false {
                newReview[self.taste_characteristics[i][2]] = self.tasteValues[i]
            }
        }
        newReview["tasteValueMax"] = self.tasteValueMax
        
        newReview["tastingNote"] = self.tastingNote.text == self.placeHolder ? "" : self.tastingNote.text
        newReview["length"] = self.tastingNote.text.count
        if self.tastingNote.text.isEmpty {
            newReview["noNote"] = true
        }
        else {
            newReview["noNote"] = false
        }
        
        newReview["deleted"] = false
        
        var imageURL: String? = nil
        var backLabelURL: String? = nil
        if let _ = self.image { // if image is not empty
            imageURL = "products_user/\(self.pid)/\(time)_\(uid).jpg"
            newReview["productImageURL"] = imageURL
        }
        if let _ = self.backLabel {
            backLabelURL = "backlabel/\(self.pid)/\(time)_\(uid).jpg"
            newReview["backLabelURL"] = backLabelURL
        }
        self.uploadImage(self.image, url: imageURL) {
            self.uploadImage(self.backLabel, url: backLabelURL)
        }
        
        ref.addDocument(data: newReview) { err in
            if let _ = err { // if error happens
                print("Error in uploading a new review")
            }
            else {
                print("Successful upload of a new review!")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ScrollView(.vertical) {
                    VStack {
                        Group {
                            HStack {
                                UploadImageView(self.$image, widthScale: 0.45, hToW: 1.5, geo: geo, text: "upload product image")
                                UploadImageView(self.$backLabel, widthScale: 0.45, hToW: 1.5, geo: geo, text: "upload back label")
                            }
                            CosmosUIView(rating: $rating, size: 60) // stars to give a rating from 1 to 5
                                .padding()
                            VStack { // drinking temperature selectors
                                HStack {
                                    Text(NSLocalizedString("choose your drinking temperature(s)", lang: authManager.user.language))
                                    Spacer()
                                }
                                TemperaturePicker(temperatures: temperatures, temperatureBools: $temperatureBools)
                            }
                                .padding()
                            TasteCharacteristicsBars(tasteValueMax: self.tasteValueMax,
                                                     taste_characteristics: self.taste_characteristics,
                                                     tasteValues: self.$tasteValues,
                                                     valueDisabled: self.$valueDisabled)
                                .padding()
                            TastingNote(_tastingNote, maxCharCount:self.maxCharCount, placeHolder: placeHolder)
                                .padding()
                        }
                        .offset(y: 20)
                    }
                    .navigationBarTitle(NSLocalizedString("write a review", lang: authManager.user.language), displayMode: .inline)
                    .navigationBarItems(leading: Button(action: {
                        writeReview.toggle()
                    }) {
                        Text(NSLocalizedString("cancel", lang: authManager.user.language))
                    }, trailing: Button(action: {
                        self.saveReview()
                        writeReview.toggle()
                    }) {
                        Text(NSLocalizedString("save", lang: authManager.user.language))
                    }
                    .disabled(self.rating==0)
                    )
                }
            }
        }
    }
}
