//
//  SortFilterView.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/02/01.
//

import SwiftUI

struct SortFilterView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var showSortFilterView: Bool
    @Binding var sortKey: String
    @Binding var filterKey: [String]
    @State var filterKeyCopy: [String]
    let sort: ()->Void
    let sortKeys: [String]
    let filterKeys: [String] = [
        "junmai-shu", "tokubetsu-junmai-shu", "junmai-ginjo-shu", "junmai-dai-ginjo-shu",
        "honjozo-shu", "tokubetsu-honjozo-shu", "ginjo-shu", "dai-ginjo-shu", "kijo-shu",
        "futsu-shu"
    ]
    
    init(show showSortFilterView: Binding<Bool>, sortBy sortKey: Binding<String>,
         sortKeys: [String], sort: @escaping ()->Void, filterBy filterKey: Binding<[String]>) {
        self._showSortFilterView = showSortFilterView
        self._sortKey = sortKey
        self.sortKeys = sortKeys
        self.sort = sort
        self._filterKey = filterKey
        self._filterKeyCopy = State(initialValue: filterKey.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text(NSLocalizedString("sort", lang: authManager.user.language))) {
                    ForEach(sortKeys, id: \.self) { key in
                        Button(action: {
                            self.sortKey = key
                        }) {
                            HStack {
                                Text(NSLocalizedString(key, lang: authManager.user.language))
                                    .foregroundColor(.black)
                                Spacer()
                                if key == self.sortKey {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        
                    }
                }
                Section(header: Text(NSLocalizedString("filter", lang: authManager.user.language))) {
                    Text("FILTERING BY TYPE OF SAKE")
                    ForEach(self.filterKeys, id: \.self) { key in
                        Button(action: {
                            if self.filterKeyCopy.contains(key) {
                                if let idx = self.filterKeyCopy.firstIndex(of: key) {
                                    self.filterKeyCopy.remove(at: idx)
                                }
                            } else {
                                self.filterKeyCopy.append(key)
                            }
                        }) {
                            HStack {
                                Text(NSLocalizedString(key, lang: authManager.user.language))
                                    .foregroundColor(.black)
                                Spacer()
                                if self.filterKeyCopy.contains(key) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarItems(leading: Button(action: {
                self.showSortFilterView.toggle()
            }) {
                Text(NSLocalizedString("cancel", lang: authManager.user.language))
            }, trailing: Button(action: { // done button
                self.sort()
                self.filterKey = self.filterKeyCopy
                self.showSortFilterView.toggle()
            }, label: {
                Text(NSLocalizedString("done", lang: authManager.user.language))
            }))
        }
    }
}
