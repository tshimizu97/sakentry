//
//  ReviewDetail.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/02/01.
//

import Firebase
import SwiftUI

struct ReviewDetail: View {
    @EnvironmentObject var authManager: AuthManager
    let review: Review
    let userImage: UIImage?
    @State var rating: Double
    
    let userInfoHeight: Double = 0.1
    @State var productImage: UIImage?
    @State var loadingProductImage: Bool = true
    @State var backLabel: UIImage?
    @State var loadingBackLabel: Bool = true
    
    init(_ review: Review, userImage: UIImage?) {
        self.review = review
        self.userImage = userImage
        self._rating = State(initialValue: review.rating)
    }
    
    func getProductImage() {
        if let imageURL = self.review.productImageURL {
            let ref = Storage.storage().reference(withPath: imageURL)
            ref.getData(maxSize: 1 * 1024 * 1024) { data, err in
                if let err = err {
                    print("Something went wrong in downloading data: \(err)")
                } else {
                    if let data = data {
                        self.productImage = UIImage(data: data)
                    }
                }
                self.loadingProductImage = false
            }
        }
    }
    
    func getBackLabelImage() {
        if let backLabelURL = self.review.backLabelURL {
            let ref = Storage.storage().reference(withPath: backLabelURL)
            ref.getData(maxSize: 1 * 1024 * 1024) { data, err in
                if let err = err {
                    print("Something went wrong in downloading data: \(err)")
                } else {
                    if let data = data {
                        self.backLabel = UIImage(data: data)
                    }
                }
                self.loadingBackLabel = false
            }
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading) { // put report option on the top right corner
                    HStack {
                        DisplayImage(self.userImage, widthScale: userInfoHeight, hToW: 1, geo: geo)
                        VStack(alignment: .leading,
                               spacing: geo.size.width * CGFloat(userInfoHeight) * 0.1) {
                            Text(self.review.userName)
                                .frame(maxHeight: geo.size.width * CGFloat(userInfoHeight) * 0.45)
                            HStack {
                                CosmosUIView(rating: self.$rating, editable: false, size: Double(geo.size.width) * userInfoHeight * 0.45)
                                Spacer()
                                Text(NSLocalizedString(self.review.date, lang: self.authManager.user.language))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    Text(self.review.tastingNote)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                    // temperature
                    // taste characteristics
                    HStack {
                        Spacer()
                        DisplayImage(self.productImage, widthScale: 0.9, geo: geo, onAppear: self.getProductImage, loading: self.$loadingProductImage, text: "HERE'S DESCRIPTION")
                            .padding()
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        DisplayImage(self.backLabel, widthScale: 0.9, geo: geo, onAppear: self.getBackLabelImage, loading: self.$loadingBackLabel, text: "HERE'S DESCRIPTION")
                            .padding()
                        Spacer()
                    }
                    // like, comment, bookmark, note options
                    // count of likes
                    // comments with name, text and time
                }
            }
        }
    }
}
