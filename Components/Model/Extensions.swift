//
//  Extensions.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/10.
//

import FirebaseAuth
import Foundation
import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct SectionData: Identifiable {
    var id = UUID()
    var header: String
    var footer: String?
    var groups: [[String]]
    var condition: String
}

func toString(dict: [String:Any]) -> String {
    var tmp: [String] = []
    for (key, value) in dict {
        let str = key + (value as! String)
        tmp.append(str)
    }
    tmp.sort()
    return tmp.joined(separator: ",")
}

func NSLocalizedString(_ key: String, lang: String? = nil) -> String {
    if let lang = lang {
        if let bundlePath = Bundle.main.path(forResource: lang, ofType: "lproj") {
            if let bundle = Bundle(path: bundlePath) {
                return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: key)
            }
        }
    }
    // if whatever error happens return the default language
    print("Error in getting selected language file.")
    return NSLocalizedString(key, comment: key)
}
