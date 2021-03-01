//
//  MyReviews.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/23.
//

import Firebase
import SwiftUI

struct MyReviews: View {
    @EnvironmentObject var authManager: AuthManager
    
    @State var myReviews: [Review] = []
    @State var products: [Product] = []
    @State var loading: Bool = true
    @State var showSortFilterView: Bool = false
    @State var sortKey: String = "latest"
    @State var listner: ListenerRegistration?
    @State var filterKey: [String] = []
    
    let sortKeys: [String] = [
        "latest", "oldest", "my_best_rated"
    ]
    
    func getMyReviews() {
        let ref: CollectionReference = Firestore.firestore().collection("reviews")
        let query: Query = (ref // just get all of undeleted my reviews
                                .whereField("uid", isEqualTo: self.authManager.user.uid)
                                .whereField("deleted", isEqualTo: false))
        self.listner = query.addSnapshotListener() { (querySnapshot, err) in
            guard let snapshot = querySnapshot else {
                print("ERROR: failed to retrieve my reviews: \(err)")
                return
            }
            var shouldGetProduct: Bool = false
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    let document: QueryDocumentSnapshot = diff.document
                    self.myReviews.append(Review(document))
                    shouldGetProduct = true
                }
                if (diff.type == .modified) {
                    let document: QueryDocumentSnapshot = diff.document
                    if let index = self.myReviews.firstIndex(where: {$0.id == document.documentID}) {
                        self.myReviews[index] = Review(document)
                    }
                }
                if (diff.type == .removed) {
                    let document: QueryDocumentSnapshot = diff.document
                    if let index = self.myReviews.firstIndex(where: {$0.id == document.documentID}) {
                        self.myReviews.remove(at: index)
                    }
                }
            }
            if shouldGetProduct {
                self.getProducts()
            }
            else {
                self.loading = false
            }
        }
    }
    
    func sortMyReviews() {
        switch self.sortKey {
        case "latest":
            // sort from newest to oldest
            self.myReviews = self.myReviews.sorted(by: { (lhs: Review, rhs: Review) in
                return lhs.time > rhs.time
            })
            
        case "oldest":
            // sort from oldest to newest
            self.myReviews = self.myReviews.sorted(by: { (lhs: Review, rhs: Review) in
                return lhs.time < rhs.time
            })
        case "my_best_rated":
            // sort from my best rated to my worst rated
            self.myReviews = self.myReviews.sorted(by: { (lhs: Review, rhs: Review) in
                return lhs.rating > rhs.rating
            })
        case "average_rating":
            print("sort by average_rating is not implemented, no sorting done.")
        default:
            print("Something went wrong, don't do any sorting here.")
        }
        self.loading = false
    }
    
    func getProducts() {
        let pids = self.myReviews.map { review in
            return review.pid
        }
        let language = self.authManager.user.language
        let productCollection = "products_\(String(describing: language))"
        let ref: CollectionReference = Firestore.firestore().collection(productCollection)
        let query: Query = ref.whereField("id", in: pids)
        query.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("ERROR: failed to retrieve products.")
                print(err)
            } else {
                let documents = querySnapshot!.documents
                for document in documents {
                    self.products.append(Product(document: document))
                }
                self.sortMyReviews()
            }
        }
    }
    
    func findProduct(_ myReview: Review) -> Product {
        let pid: String = myReview.pid
        return self.products.first(where: { product in product.id == pid}) ?? Product("unknown")
    }
    
    var body: some View {
        List {
            if self.loading {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .onAppear() {
                            self.getMyReviews()
                        }
                    Spacer()
                }
            }
            else { // if data is loaded
                if myReviews.isEmpty {
                    // if there is no my review
                    Text("YOU HAVEN'T WRITTEN ANY REVIEW!")
                }
                else {
                    // if there are my reviews
                    ForEach(self.myReviews) { myReview in
                        Section {
                            let product: Product = self.findProduct(myReview)
                            if self.filterKey.isEmpty || self.filterKey.contains(product.type) {
                                ProductRow(product: product,
                                           setNavigationLink: product.id=="unknown" ? false : true)
                                ReviewRow(myReview)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(
            NSLocalizedString(
                "my_reviews", lang: authManager.user.language),
                displayMode: .inline
        )
        .navigationBarItems(trailing: Button(action: { // sort button
            self.showSortFilterView.toggle()
        }, label: {
            Text(NSLocalizedString("sort_filter", lang: authManager.user.language))
        }))
        .fullScreenCover(isPresented: $showSortFilterView) {
            SortFilterView(show: $showSortFilterView, sortBy: self.$sortKey,
                           sortKeys: self.sortKeys, sort: self.sortMyReviews,
                           filterBy: self.$filterKey)
        }
        .onDisappear() {
            // maybe don't use this at all or deal with this better
            // don't want to remove when a new view is put on the stack
            // may want to remove when this view is popped
            //self.listner?.remove()
        }
    }
}
