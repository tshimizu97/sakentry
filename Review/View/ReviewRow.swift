//
//  ReviewRow.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/30.
//


import SwiftUI

struct ReviewRow: View {
    @EnvironmentObject var authManager: AuthManager
    let review: Review
    @State var rating: Double
    @State var userImage: UIImage?
    @State var goToProfile: Bool = false
    
    init(_ review: Review) {
        self.review = review
        self._rating = State(initialValue: review.rating)
    }
    
    func like() {
        // behavior if like button is clicked
    }
    
    func comment() {
        // behavior if comment button is clicked
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink(destination: ReviewDetail(self.review, userImage: self.userImage)) {
                VStack(alignment: .leading) {
                    Text(self.review.tastingNote)
                    CosmosUIView(rating: self.$rating, editable: false, size: 15)
                }
            }
            HStack {
                HStack {
                    Image(systemName: "photo") // change to userImage if needed
                    VStack(alignment: .leading) {
                        Text(self.review.uid != self.authManager.user.uid ? self.review.userName : NSLocalizedString("you", lang: authManager.user.language))
                            .font(.caption)
                        Text(NSLocalizedString(self.review.date, lang: authManager.user.language))
                            .font(.caption)
                    }
                }
                .onTapGesture {
                    if self.review.uid != self.authManager.user.uid {
                        self.goToProfile.toggle()
                    }
                }
                .background(NavigationLink(destination: Profile(self.review.uid), isActive: self.$goToProfile) { EmptyView() }.disabled(!self.goToProfile))
                Spacer()
                Text("LIKES")
                    .onTapGesture {
                        self.like()
                    }
                    .font(.caption)
                Text("COMMENTS")
                    .onTapGesture {
                        self.comment()
                    }
                    .font(.caption)
            }
        }
    }
}

