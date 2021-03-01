//
//  Reviews.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/24.
//

import Firebase
import SwiftUI

struct Reviews: View {
    @EnvironmentObject var authManager: AuthManager
    let pid: String
    let vintage: Int?
    @Binding var writeReview: Bool
    
    @State var ready: [Bool] = [false, false, false]
    @State var selection: Int = 0
    let tabs: [String] = ["helpful", "recent", "following"]
    let nReviewsToDisplay: Int = 3
    @State var reviews: [[Review]] = [[], [], []]
    let n_reviews_displayed: Int = 3
    
    init(pid: String, vintage: Int?, writeReview: Binding<Bool>) {
        //UISegmentedControl.appearance().backgroundColor = .blue
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.01)
        
        self.pid = pid
        self.vintage = vintage
        self._writeReview = writeReview
    }
    
    func getReviews() {
        let ref: CollectionReference = Firestore.firestore().collection("reviews")
        let basicQuery: Query = (ref // helpful review should come first
                                .whereField("pid", isEqualTo: self.pid)
                                .whereField("noNote", isEqualTo: false)
                                .whereField("deleted", isEqualTo: false))
        var query: Query
        if self.selection == 0 { // sorting from most useful to least useful
            query = basicQuery
                .order(by: "likeCount", descending: true)
                .order(by: "time", descending: true)
        }
        else if self.selection == 1 { // sorting from most recent to least recent
            query = basicQuery.order(by: "time", descending: true)
        }
        else { // reviews only from those the user is following, and sorting by time implicitly
            if self.authManager.user.followings.count > 0 {
                query = basicQuery.whereField("uid", in: self.authManager.user.followings)
            } else {
                self.ready[self.selection] = true
                return // don't collect reviews indeed
            }
        }
        query = query.limit(to: self.nReviewsToDisplay)
        query.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("ERROR: failed to retrieve reviews.")
                print(err)
            } else {
                for document in querySnapshot!.documents {
                    self.reviews[self.selection].append(Review(document))
                }
                self.ready[self.selection] = true
            }
        }
    }
    
    var body: some View {
        Group { // Reviews is enclosed in one section of List
            HorizontalPicker(selection: self.$selection, tabs: self.tabs)
            if self.ready[self.selection] {
                if self.reviews[self.selection].count == 0 { // no review available
                    Text(NSLocalizedString("no review available, be the first one to write a review", lang: authManager.user.language))
                }
                else { // there are reviews
                    ForEach(self.reviews[self.selection]) { review in
                        ReviewRow(review)
                    }
                    NavigationLink(destination: MoreReviews()) {
                        Text(NSLocalizedString("read more reviews", lang: authManager.user.language))
                    }
                }
            } else {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .onAppear() {
                            self.getReviews()
                        }
                    Spacer()
                }
            }
            Button(action: {
                writeReview.toggle()
            }) {
                Text(NSLocalizedString("write a review", lang: authManager.user.language))
            }
        }
    }
}
