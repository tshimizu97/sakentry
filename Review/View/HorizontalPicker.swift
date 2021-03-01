//
//  HorizontalPicker.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2/15/21.
//

import SwiftUI

struct HorizontalPicker: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var selection: Int
    let tabs: [String]
    
    var body: some View {
        HStack {
            ForEach(0..<tabs.count) { i in
                Text(NSLocalizedString(tabs[i], lang: self.authManager.user.language))
                    .foregroundColor(i == self.selection ? .black : .blue)
                    .font(.caption)
                    .tag(i)
                    .onTapGesture {
                        self.selection = i
                    }
            }
        }
    }
}
