//
//  Review.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/30.
//

import Firebase
import Foundation
import SwiftUI

struct Review: Hashable, Codable, Identifiable {
    var tasteValueMax: Double
    let taste_characteristics: [[String]] = [
        ["light", "bold", "body"],
        ["clean", "rich", "umami"],
        ["dry", "sweet", "sweetness"],
        ["soft", "acidic", "acidity"],
        ["smooth", "bitter", "bitterness"],
        ["watery", "thick", "mouthfeel"]
    ]
    
    let id: String // review id
    let pid: String
    let uid: String
    let userName: String
    var vintage: Int?
    let date: String
    let time: Double
    var rating: Double
    var tasteValues: [Double]
    var valueDisabled: [Bool]
    var tastingNote: String
    var length: Int
    var commentCount: Int
    let productImageURL: String?
    let backLabelURL: String?
    
    init(_ document: QueryDocumentSnapshot) {
        self.tasteValueMax = 16
        
        self.id = document.documentID
        let data = document.data()
        self.pid = data["pid"] as! String
        self.uid = data["uid"] as! String
        self.userName = data["userName"] as! String
        self.vintage = data["vintage"] as? Int
        self.date = data["date"] as! String
        self.time =  data["time"] as? Double ?? 0
        self.rating = data["rating"] as! Double
        let oldTastaValue: Double? = data["tasteValueMax"] as? Double
        var tasteValueRatio: Double
        if let oldTastaValue = oldTastaValue {
            tasteValueRatio = oldTastaValue / self.tasteValueMax
        }
        else {
            tasteValueRatio = 1
        }
        self.tasteValues = []
        self.valueDisabled = []
        for taste in self.taste_characteristics {
            if let tasteValue = data[taste[2]] as? Double {
                tasteValues.append(tasteValue * tasteValueRatio)
                valueDisabled.append(false)
            }
            else {
                tasteValues.append(self.tasteValueMax / 2)
                valueDisabled.append(true)
            }
        }
        self.tastingNote = data["tastingNote"] as! String
        self.length = data["length"] as! Int
        self.commentCount = data["commentCount"] as! Int
        self.productImageURL = data["productImageURL"] as? String
        self.backLabelURL = data["backLabelURL"] as? String
    }
}
