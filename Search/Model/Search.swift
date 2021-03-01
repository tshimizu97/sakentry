//
//  Search.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/08.
//
//  Search functionality

import Firebase
import Foundation
import SwiftUI

let langs = ["ja", "en"] // list of available languages

class Search: ObservableObject {
    let pageSize: Int
    let conditions: [String:Any]
    
    @Published var results: [Product] = []
    @Published var loading: Bool = true
    let ref: CollectionReference
    var query: Query
    var lastID: String?
    var fullyLoaded: Bool = false
    var cache_path: String
    var dataToCache: [NSDictionary] = []
    
    init(conditions: [String:Any], pageSize: Int) {
        self.conditions = conditions
        self.pageSize = pageSize
        let lang = NSLocalizedString("lang_code", comment: "")
        let filename = lang + "," + toString(dict: conditions)
        self.cache_path = NSHomeDirectory() + "/Library/Caches/" + filename + ".plist"
        let db = Firestore.firestore()
        // find a suitable collection based on language setting
        if lang == "ja" {
            // Japanese
            self.ref = db.collection("products_ja")
        }
        else {
            // English
            self.ref = db.collection("products_en")
        }
        self.query = ref.order(by: "id")
        
        self.setup()
    }
    
    // set up query setting
    func setup(){
        // initialize search results
        self.results = []
        self.loading = true
        
        self.checkCache() // this set self.loading=false if cache is found
        
        if let type = conditions["type"] as? String {
            if type == "junmai-kei" {
                self.query = self.query.whereField("type", in: ["junmai-kei", "junmai-shu",
                                                    "tokubetsu-junmai-shu", "junmai-ginjo-shu",
                                                    "junmai-dai-ginjo-shu"])
            }
            
            else if type == "honjozo-kei" {
                self.query = self.query.whereField("type", in: ["honjozo-kei", "honjozo-shu",
                                                    "tokubetsu-honjozo-shu", "ginjo-shu",
                                                    "dai-ginjo-shu"])
            }
            else {
                self.query = self.query.whereField("type", isEqualTo: type)
            }
        }
        
        if conditions["smv"] != nil {
            NotImplemented()
        }
        
        if conditions["polishing_rate"] != nil {
            NotImplemented()
        }
        
        if conditions["acidity"] != nil {
            NotImplemented()
        }
        
        if conditions["amino_acid"] != nil {
            NotImplemented()
        }
    }
    
    // load data from cache if available
    func checkCache() {
        if FileManager.default.fileExists(atPath: self.cache_path) {
            // check if cache is up to date {
            if let data = NSArray(contentsOf: URL(fileURLWithPath: self.cache_path)) {
                self.dataToCache = data as? [NSDictionary] ?? []
                self.results = data.map { product in
                    return Product(dictionary: product as! NSDictionary)
                }
                if let lastID = self.results.last?.id {
                    self.lastID = lastID
                }
            }
            //  }
            self.loading = false
        }
    }
    
    // load products in the next page
    func nextPage() {
        self.loading = true
        // specify products in the next page
        if let lastID = self.lastID {
            self.query = self.query.whereField("id", isGreaterThan: Int(lastID))
        }
        self.query = self.query.limit(to: self.pageSize)
        
        self.query.getDocuments { (snapshot, err) in
            if let err = err {
                print("ERROR: \(err)")
            } else {
                let newDocument = snapshot!.documents.map { document in
                    return Product(document: document)
                }
                self.results += newDocument
                self.loading = false
                if snapshot!.documents.count < self.pageSize {
                    self.fullyLoaded = true
                }
                if snapshot!.documents.count != 0 {
                    self.saveToCache(test: snapshot!)
                    if let newLast = self.results.last?.id {
                        self.lastID = newLast
                    }
                }
            }
        }
    }
    
    func localFilter(taste_category: String) {
        if taste_category == "unselected" {
            return
        }
        
    }
    
    // save the loaded product data to the local cache using NSArray
    func saveToCache(test: QuerySnapshot) {
        do {
            let newData = test.documents.map { document -> NSDictionary in
                var product = document.data()
                product["id"] = document.documentID
                return NSDictionary(dictionary: product)
            }
            self.dataToCache += newData
            let filecontent = NSArray(array: self.dataToCache)
            try filecontent.write(to: URL(fileURLWithPath: self.cache_path))
        }
        catch {
            print("ERROR: \(error)")
        }
    }
}
