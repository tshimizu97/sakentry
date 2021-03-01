//
//  FilterList.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/10.
//

import SwiftUI

let sections = [
    SectionData(header: "search sake by type",
                footer: "see what different types of sake mean",
                groups: [["junmai-kei", "junmai-shu", "tokubetsu-junmai-shu", "junmai-ginjo-shu", "junmai-dai-ginjo-shu"],
                         ["honjozo-kei", "honjozo-shu", "tokubetsu-honjozo-shu", "ginjo-shu", "dai-ginjo-shu"],
                         ["kijo-shu"],
                         ["futsu-shu"]],
                condition: "type")
]

struct FilterList: View {
    @EnvironmentObject var authManager: AuthManager
    
    let pageSize: Int = 20
    
    var body: some View {
        List {
            ForEach(sections) { section in
                Section(header: Text(NSLocalizedString(section.header, lang: authManager.user.language))) {
                    ForEach(section.groups, id: \.self) { group in
                        let condition = section.condition
                        let groupName = group[0]
                        NavigationLink(destination: FilterResults([condition: groupName], pageSize: self.pageSize)) {
                            Text(NSLocalizedString(groupName, lang: authManager.user.language))
                        }
                        if group.count > 1 {
                            ForEach(group[1...], id: \.self) {item in
                                NavigationLink(destination: FilterResults([condition: item], pageSize: self.pageSize)) {
                                    Text("   \(NSLocalizedString(item, lang: authManager.user.language))")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
