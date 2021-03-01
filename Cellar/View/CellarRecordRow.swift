//
//  CellarRecordRow.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/02/06.
//

import Firebase
import SwiftUI

struct CellarRecordRow: View {
    @EnvironmentObject var authManager: AuthManager
    let record: CellarRecord
    let drunk: Bool
    let bottles: String
    let vintageToShow: String
    
    init(record: CellarRecord) {
        self.record = record
        self.drunk = record.drunk
        if record.nBottles > 1 {
            self.bottles = "bottles"
        }
        else {
            self.bottles = "bottle"
        }
        if let vintage = self.record.vintage {
            self.vintageToShow = String(vintage)
        } else {
            self.vintageToShow = "nv"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack { // number of bottles, time, vintage
                Text("\(self.record.nBottles) \(NSLocalizedString(bottles, lang: authManager.user.language)) (\(NSLocalizedString(self.vintageToShow, lang: authManager.user.language)))")
                Text("\(NSLocalizedString("cellared", lang: authManager.user.language)): \(NSLocalizedString(self.record.date_add, lang: authManager.user.language))")
                if let date_drunk = self.record.date_drunk {
                    Text("\(NSLocalizedString("drunk", lang: authManager.user.language)): \(NSLocalizedString(date_drunk, lang: authManager.user.language))")
                }
            }
            .font(.body)
            if let notes = self.record.notes {
                Text(notes)
                    .lineLimit(1)
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
        }
        .foregroundColor(self.drunk ? .gray : .black)
    }
}
