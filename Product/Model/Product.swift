//
//  Product.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/06.
//
//  Definition of Product struct

import Combine
import Firebase
import Foundation
import SwiftUI

struct Product: Hashable, Codable, Identifiable {
    let id: String
    let name: String
    let name_kana: String?
    let type: String
    let taste_category: String?
    let subcategories: [String]?
    let rice_varieties: [String]?
    let yeasts: [String]?
    let polishing_rate: Double?
    let dryness: Double?
    let richness: Double?
    let abv_high: Double?
    let abv_low: Double?
    let acidity: Double?
    let amino_acid: Double?
    let smv: Double?
    let brand: String
    let brand_kana: String?
    let city: String
    let prefecture: String
    let copyright: String?
    let filter: [String:Bool]
    let img_urls: [String]?
    
    init(dictionary data: NSDictionary) {
        self.id = data["id"] as! String
        self.name = data["name"] as! String
        self.name_kana = data["name_kana"] as? String
        self.type = data["type"] as! String
        self.taste_category = data["taste_category"] as? String
        self.subcategories = data["subcategories"] as? [String]
        self.rice_varieties = data["rice_varieties"] as? [String]
        self.yeasts = data["yeasts"] as? [String]
        self.polishing_rate = data["polishing_rate"] as? Double
        self.dryness = data["dryness"] as? Double
        self.richness = data["richness"] as? Double
        self.abv_low = data["abv_low"] as? Double
        self.abv_high = data["abv_high"] as? Double
        self.acidity = data["acidity"] as? Double
        self.amino_acid = data["amino_acid"] as? Double
        self.smv = data["smv"] as? Double
        self.brand = data["brand"] as! String
        self.brand_kana = data["brand_kana"] as? String
        self.city = data["city"] as! String
        self.prefecture = data["prefecture"] as! String
        self.copyright = data["copyright"] as? String
        self.filter = data["filter"] as! [String:Bool]
        self.img_urls = data["img_urls"] as? [String]
    }
    
    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID
        let data = document.data()
        self.name = data["name"] as! String
        self.name_kana = data["name_kana"] as? String
        self.type = data["type"] as! String
        self.taste_category = data["taste_category"] as? String
        self.subcategories = data["subcategories"] as? [String]
        self.rice_varieties = data["rice_varieties"] as? [String]
        self.yeasts = data["yeasts"] as? [String]
        self.polishing_rate = data["polishing_rate"] as? Double
        self.dryness = data["dryness"] as? Double
        self.richness = data["richness"] as? Double
        self.abv_low = data["abv_low"] as? Double
        self.abv_high = data["abv_high"] as? Double
        self.acidity = data["acidity"] as? Double
        self.amino_acid = data["amino_acid"] as? Double
        self.smv = data["smv"] as? Double
        self.brand = data["brand"] as! String
        self.brand_kana = data["brand_kana"] as? String
        self.city = data["city"] as! String
        self.prefecture = data["prefecture"] as! String
        self.copyright = data["copyright"] as? String
        self.filter = data["filter"] as! [String:Bool]
        self.img_urls = data["img_urls"] as? [String]
    }
    
    init(_ unknown: String) {
        if unknown != "unknown" {
            NonFatalError()
        }
        self.id = "unknown"
        self.name = "unknown"
        self.name_kana = nil
        self.type = "unknown_type"
        self.taste_category = "unknown_taste"
        self.subcategories = []
        self.rice_varieties = []
        self.yeasts = []
        self.polishing_rate = nil
        self.dryness = nil
        self.richness = nil
        self.abv_low = nil
        self.abv_high = nil
        self.acidity = nil
        self.amino_acid = nil
        self.smv = nil
        self.brand = "unknown_brand"
        self.brand_kana = nil
        self.city = "unknown_city"
        self.prefecture = "unknown_pref"
        self.copyright = nil
        self.filter = [String:Bool]()
        self.img_urls = nil
    }
}
