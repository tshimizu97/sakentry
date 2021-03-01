//
//  FilterSort.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/18.
//

import SwiftUI

struct FilterSort: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var changeCondition: Bool
    var search: Search
    @State var taste_category: Int = 0
    @State var sort: String?
    @State var ascending: Bool = true
    let taste_categories: [String] = ["unselected", "sweet_rich", "sweet_light", "dry_rich", "dry_light"]
    
    var body: some View {
        NavigationView {
            Form {
                Picker(selection: $taste_category, label: Text(NSLocalizedString("choose taste_category", lang: authManager.user.language))) {
                    ForEach (0..<taste_categories.count) { i in
                        Text(NSLocalizedString(taste_categories[i], lang: authManager.user.language))
                    }
                }
            }
            .navigationBarTitle(
                NSLocalizedString(
                    "filter_sort", lang: authManager.user.language),
                    displayMode: .inline
            )
            .navigationBarItems(trailing: Button(action: {
                self.changeCondition.toggle()
            }, label: {
                Text(NSLocalizedString("save", lang: authManager.user.language))
            }))
        }
        .onDisappear() {
            
        }
    }
}

