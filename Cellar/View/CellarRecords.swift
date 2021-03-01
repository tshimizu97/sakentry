//
//  CellarRecords.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/02/06.
//

import Firebase
import SwiftUI

struct CellarRecords: View {
    @EnvironmentObject var authManager: AuthManager
    let product: Product
    
    @State var records: [CellarRecord] = []
    @State var bottleCounts: Int = 0
    @State var ready: Bool = false
    @State var showAddToCellarView: Bool = false
    
    func sortByVintage() {
        self.records = self.records.sorted(by: {(lhs: CellarRecord, rhs: CellarRecord) in
            let leftVintage: Int = lhs.vintage ?? 0
            let rightVintage: Int = rhs.vintage ?? 0
            return leftVintage > rightVintage
        })
    }
    
    func getRecords() {
        let ref: CollectionReference = Firestore.firestore().collection("cellar")
        let query: Query = (ref
                                .whereField("uid", isEqualTo: self.authManager.user.uid)
                                .whereField("pid", isEqualTo: product.id)
                                .whereField("deleted", isEqualTo: false)
                                .order(by: "time", descending: true))
        query.addSnapshotListener() { (querySnapshot, err) in
            guard let snapshot = querySnapshot else {
                print("ERROR: failed to retrieve bottles in cellar: \(err)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    let document: QueryDocumentSnapshot = diff.document
                    if !(document.data()["drunk"] as? Bool ?? false) {
                        self.bottleCounts += document.data()["nBottles"] as? Int ?? 1
                    }
                    if !self.ready {
                        self.records.append(CellarRecord(document: document))
                    }
                    else {
                        self.records.insert(CellarRecord(document: document), at: 0)
                    }
                }
                if (diff.type == .modified) {
                    let document: QueryDocumentSnapshot = diff.document
                    if let index = self.records.firstIndex(where: {$0.id == document.documentID}) {
                        let newCount = document.data()["nBottles"] as? Int ?? 1
                        let oldCount = self.records[index].nBottles
                        let changeNBottles: Int = newCount - oldCount
                        self.records[index] = CellarRecord(document: document)
                        self.bottleCounts += changeNBottles
                    }
                }
                if (diff.type == .removed) {
                    let document: QueryDocumentSnapshot = diff.document
                    if let index = self.records.firstIndex(where: {$0.id == document.documentID}) {
                        self.records.remove(at: index)
                        self.bottleCounts -= document.data()["nBottles"] as? Int ?? 1
                    }
                }
            }
            self.sortByVintage()
            self.ready = true
        }
    }
    
    var body: some View {
        if ready {
            List {
                ProductRow(product: product, setNavigationLink: false)
                HStack {
                    Spacer()
                    VStack {
                        Text("\(self.bottleCounts)")
                        Text(NSLocalizedString("bottles", lang: authManager.user.language))
                    }
                    Spacer()
                    Text(NSLocalizedString("add_to_cellar", lang: authManager.user.language))
                        .onTapGesture {
                            showAddToCellarView.toggle()
                        }
                        .fullScreenCover(isPresented: $showAddToCellarView) {
                            AddToCellarView(product: self.product, showAddToCellarView: self.$showAddToCellarView)
                        }
                    Spacer()
                }
                if self.bottleCounts > 0 {
                    Section(header: Text(NSLocalizedString("log", lang: authManager.user.language))) {
                        ForEach(self.records, id: \.self) { record in
                            CellarRecordRow(record: record)
                        }
                    }
                }
            }
        }
        else {
            Text("LOADING DATA")
                .onAppear() {
                    self.getRecords()
                }
        }
    }
}
