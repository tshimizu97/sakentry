//
//  ProductDetail.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/08.
//

import Firebase
import SwiftUI

struct ProductDetail: View {
    @EnvironmentObject var authManager: AuthManager
    let product: Product
    @Binding var image: UIImage?
    
    @State var vintage: Int?
    @State var rating: Double = 0
    @State var showMyLog: Bool = false
    @State var myReview: Review?
    @ObservedObject var tastingNote = TextManager(limit: 512)
    @State var showWriteReview: Bool = false
    @State var showAddToCellar: Bool = false
    
    func getMyLog() {
        let ref: CollectionReference = Firestore.firestore().collection("reviews")
        let query: Query = (ref // just get all of undeleted my reviews
                                .whereField("pid", isEqualTo: self.product.id)
                                .whereField("uid", isEqualTo: self.authManager.user.uid)
                                .whereField("deleted", isEqualTo: false)
                                .order(by: "time", descending: true)
                                .limit(to: 1))
        query.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("ERROR: failed to retrieve a review")
                print(err)
            } else {
                let documents: [QueryDocumentSnapshot] = querySnapshot!.documents
                if !documents.isEmpty {
                    self.myReview = Review(documents[0])
                    self.showMyLog = true
                }
            }
        }
    }
    
    var body: some View {
        NavigationLink(destination: CellarRecords(product: self.product), isActive: self.$showAddToCellar) {
            EmptyView()
        }
        List { // container
            Section {
                VStack(alignment: .leading) {
                    HStack(alignment: .center) { // image + average rating (number + star display)
                        Spacer()
                        if let image = self.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 225)
                        }
                        else {
                            Image(systemName: "photo") // image not available
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 225)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Spacer()
                            CosmosUIView(rating: $rating, editable: false, size: 30)// put average rating here
                            Spacer()
                            if let _ = product.img_urls {
                                if let copyright = product.copyright {
                                    Text(copyright)
                                        .font(.caption)
                                }
                            }
                        }
                        Spacer()
                    }
                    VStack(alignment: .leading) { // basic info
                        Text(product.brand)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(product.name)
                            .font(.title)
                            .foregroundColor(.primary)
                        Text("\(NSLocalizedString(product.type, lang: authManager.user.language)) from \(NSLocalizedString(product.city, lang: authManager.user.language)), \(NSLocalizedString(product.prefecture, lang: authManager.user.language))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                HStack(spacing: 0) { // action options
                    Text(NSLocalizedString("review", lang: authManager.user.language)) // add "star" image
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .font(.caption)
                        .onTapGesture {
                            self.showWriteReview.toggle()
                        }
                    Text(NSLocalizedString("cellar", lang: authManager.user.language)) // find some image for fridge or sth
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .font(.caption)
                        .onTapGesture {
                            self.showAddToCellar.toggle()
                        }
                    Text(NSLocalizedString("bookmark", lang: authManager.user.language)) // add "bookmark" image
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .font(.caption)
                        .onTapGesture {
                            // add the product to bookmark
                        }
                    Text(NSLocalizedString("note", lang: authManager.user.language)) // add "square.and.pencil" image
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .font(.caption)
                        .onTapGesture {
                            // add the product to bookmark
                        }
                }
            }
            // add my log if there's any in log
            if showMyLog {
                Section(header: Text(NSLocalizedString("my_log", lang: authManager.user.language))) {
                    if let myReview = self.myReview {
                        ReviewRow(myReview)
                    }
                    // if in cellar, show a link to cellar detail
                    // if in pictured, show a link to pictured detail
                }
            }
            
            // taste characteristics diagram based on user
            Section(header: Text(NSLocalizedString("taste chracteristics", lang: authManager.user.language))) {
                Text("TASTE CHARACTERISTICS HERE")
            }
            
            // flavour characteristics based on user reviews
            Section(header: Text(NSLocalizedString("flavour chracteristics", lang: authManager.user.language))) {
                Text("FLAVOUR CHARACTERISTICS HERE")
            }
            
            // reviews
            Section(header: Text(NSLocalizedString("reviews", lang: authManager.user.language))) {
                Reviews(pid: product.id, vintage: vintage, writeReview: self.$showWriteReview)
            }
            
            // product details
            Section(header: Text(NSLocalizedString("product details", lang: authManager.user.language))) {
                if let taste_category: String = product.taste_category { // taste_category
                    HStack {
                        Text(NSLocalizedString("taste_category", lang: authManager.user.language))
                        Spacer()
                        Text(NSLocalizedString(taste_category, lang: authManager.user.language))
                    }
                }
                HStack { // smv
                    Text(NSLocalizedString("smv", lang: authManager.user.language))
                    Spacer()
                    if let smv: Double = product.smv {
                        Text("\(smv)")
                    }
                    else {
                        Text(NSLocalizedString("n/a", lang: authManager.user.language))
                    }
                }
                HStack { // acidity
                    Text(NSLocalizedString("acidity", lang: authManager.user.language))
                    Spacer()
                    if let acidity = product.acidity {
                        Text("\(acidity)")
                    }
                    else {
                        Text(NSLocalizedString("n/a", lang: authManager.user.language))
                    }
                }
                HStack { // amino_acid
                    Text(NSLocalizedString("amino_acid", lang: authManager.user.language))
                    Spacer()
                    if let amino_acid = product.amino_acid {
                        Text("\(amino_acid)")
                    }
                    else {
                        Text(NSLocalizedString("n/a", lang: authManager.user.language))
                    }
                }
                HStack { // rice_varieties
                    Text(NSLocalizedString("rice_varieties", lang: authManager.user.language))
                    Spacer()
                    if let rice_variety = product.rice_varieties {
                        Text(rice_variety.joined(separator: ", "))
                    }
                    else {
                        Text(NSLocalizedString("n/a", lang: authManager.user.language))
                    }
                }
                HStack { // polishing_rate
                    Text(NSLocalizedString("polishing_rate", lang: authManager.user.language))
                    Spacer()
                    if let polishing_rate = product.polishing_rate {
                        Text("\(polishing_rate)")
                    }
                    else {
                        Text(NSLocalizedString("n/a", lang: authManager.user.language))
                    }
                }
                HStack { // abv
                    Text(NSLocalizedString("abv", lang: authManager.user.language))
                    Spacer()
                    if let high = product.abv_high {
                        if let low = product.abv_low {
                            if high == low {
                                Text("\(high) %")
                            }
                            else {
                                Text("\(low) ~ \(high) %")
                            }
                        }
                    }
                    else {
                        Text(NSLocalizedString("n/a", lang: authManager.user.language))
                    }
                }
            }
            
            // brewery info
            Section(header: Text(NSLocalizedString("brewery", lang: authManager.user.language))) {
                VStack(alignment: .leading) {
                    Text("BREWERY NAME") // here add function to remove prefecture part
                    Text("BREWERY LOCATION")
                }
            }
        }
        .listStyle(GroupedListStyle())
        .environment(\.defaultMinListRowHeight, 10)
        .onAppear() {
            self.getMyLog()
        }
        .fullScreenCover(isPresented: $showWriteReview) {
            AddReview(writeReview: $showWriteReview, pid: self.product.id, vintage: self.vintage)
        }
    }
}
