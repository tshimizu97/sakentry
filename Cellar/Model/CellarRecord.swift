//
//  CellarRecord.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/02/06.
//

import Firebase
import Foundation

struct CellarRecord: Hashable, Codable, Identifiable {
    let id: String // unique id to each cellared bottle
    let uid: String
    let pid: String
    let time: Double
    let date_add: String
    let date_drunk: String?
    let notes: String?
    let drunk: Bool
    let deleted: Bool
    let vintage: Int?
    let nBottles: Int
    let imageURL: String?
    
    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID
        let data = document.data()
        self.uid = data["uid"] as? String ?? "unknown"
        self.pid = data["pid"] as? String ?? "unknown"
        self.time = data["time"] as? Double ?? 0
        self.date_add = data["date_add"] as? String ?? "unknown"
        self.date_drunk = data["date_drunk"] as? String
        self.notes = data["notes"] as? String
        self.drunk = data["drunk"] as? Bool ?? false
        self.deleted = data["deleted"] as? Bool ?? false
        self.vintage = data["vintage"] as? Int
        self.nBottles = data["nBottles"] as? Int ?? 1
        self.imageURL = data["imageURL"] as? String
    }
}
