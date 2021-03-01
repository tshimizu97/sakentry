//
//  SearchPage.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/08.
//
//  View of search tab

import FirebaseAuth
import SwiftUI

struct SearchPage: View {
    @EnvironmentObject var authManager: AuthManager
    
    @State var text = ""
    @State var searched = false
    @State var typing = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    TextField(NSLocalizedString("search sake", lang: authManager.user.language), text: $text) { typing in
                        self.typing = typing
                    }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    Spacer()
                    Button (action: {
                        // Here's response to the Cancel button
                        self.text = ""
                        self.hideKeyboard()
                    }) {
                        Text(NSLocalizedString("cancel", lang: authManager.user.language))
                    }
                    .disabled(!typing)
                }
                .padding()
                if searched { // change this appropriately so it apperes only when search is done by "return"
                    SearchResult()
                }
                else {
                    FilterList()
                }
            }
            .navigationBarTitle(NSLocalizedString("search sake", lang: authManager.user.language), displayMode: .inline)
        }
    }
}
