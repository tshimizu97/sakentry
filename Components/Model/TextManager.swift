//
//  TextManager.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/31.
//

import SwiftUI

class TextManager: ObservableObject {
    @Published var text: String = "" {
        didSet {
            if text.count > characterLimit && oldValue.count <= characterLimit {
                let to: String.Index = text.index(text.startIndex, offsetBy: self.characterLimit)
                text = String(text[..<to])
            }
        }
    }
    let characterLimit: Int

    func isEmpty() -> Bool {
        return self.text.isEmpty
    }
    
    init(limit: Int){
        characterLimit = limit
    }
}
