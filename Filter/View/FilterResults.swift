//
//  FilterResults.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/10.
//

import FirebaseAuth
import SwiftUI

struct FilterResults: View {
    @EnvironmentObject var authManager: AuthManager
    var conditions: [String:Any]
    @ObservedObject var search: Search
    let pageSize: Int
    
    @State var changeCondition: Bool = false
    
    init(_ conditions: [String:Any], pageSize: Int) {
        self.conditions = conditions
        self.pageSize = pageSize
        self.search = Search(conditions: conditions, pageSize: pageSize)
    }
    
    func lastRow(_ rowNumber: Int) -> Bool {
        return rowNumber == self.pageSize - 1
    }
    
    func loadDataIfNeeded() {
        if !self.search.fullyLoaded { // if data not fully loaded yet
            self.search.nextPage()
        }
    }
    
    var body: some View {
        List {
            ForEach(0..<self.search.results.count, id: \.self) { i in
                let product = self.search.results[i]
                ProductRow(product: product)
                    .onAppear() {
                        if i == self.search.results.count - 1 {
                            self.loadDataIfNeeded()
                        }
                    }
            }
            if self.search.loading {
                HStack{
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .onAppear() {
                            if self.search.results.isEmpty { // if there's no data to show, then get the next page
                                self.search.nextPage()
                            }
                        }
                    Spacer()
                }
            }
        }
        .navigationBarTitle(
            NSLocalizedString(
                "search results", lang: authManager.user.language),
                displayMode: .inline
        )
        .navigationBarItems(trailing: Button(action: {
            self.changeCondition.toggle()
        }, label: {
            Text(NSLocalizedString("filter", lang: authManager.user.language))
        }))
        .fullScreenCover(isPresented: $changeCondition) {
            FilterSort(changeCondition: $changeCondition, search: search)
        }
    }
}
