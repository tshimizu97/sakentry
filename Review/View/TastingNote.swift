//
//  TastingNote.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/31.
//

import SwiftUI

struct TastingNote: View {
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var tastingNote: TextManager
    let placeHolder: String
    
    let maxCharCount: Int
    let title: String?
    
    init(_ tastingNote: ObservedObject<TextManager>, maxCharCount: Int, placeHolder: String, title: String?="tasting_notes") {
        self._tastingNote = tastingNote
        self.maxCharCount = maxCharCount
        self.placeHolder = placeHolder
        self.title = title
    }
    
    var body: some View {
        VStack {
            if let title = self.title {
                HStack {
                    Text(NSLocalizedString(title, lang: authManager.user.language))
                    Spacer()
                }
            }
            ZStack(alignment: .top) {
                if tastingNote.isEmpty() {
                    HStack {
                        Text(NSLocalizedString(self.placeHolder, lang: authManager.user.language))
                            .foregroundColor(.gray)
                            .padding(.leading, 5)
                            .padding(.top, 7)
                        Spacer()
                    }
                }
                TextEditor(text: $tastingNote.text)
                    .frame(minHeight: 200)
                    .opacity(self.tastingNote.isEmpty() ? 0.1 : 1)
            }
            .border(Color.gray)
            HStack {
                Spacer()
                Text("\(self.tastingNote.text.count) / \(self.maxCharCount) \(NSLocalizedString("characters", lang: authManager.user.language))")
                    .foregroundColor(.gray)
            }
        }
    }
}
