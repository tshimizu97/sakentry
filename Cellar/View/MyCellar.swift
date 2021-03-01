//
//  MyCellar.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/02/03.
//

import Firebase
import SwiftUI

struct MyCellar: View {
    @EnvironmentObject var authManager: AuthManager
    
    @State var loading: Bool = true // if data is still loading
    @State var listner: ListenerRegistration?
    @State var records: [CellarRecord] = []
    @State var products: [Product] = []
    @State var sortKey: String = "newest_vintage"
    @State var filterKey: [String] = []
    @State var bottleCounts: Int = 0
    @State var showSortFilterView: Bool = false
    
    let sortKeys = [
        "latest", "oldest", "newest_vintage", "oldest_vintage"
    ]
    
    func getRecords () {
        let ref: CollectionReference = Firestore.firestore().collection("cellar")
        let query: Query = (ref
                                .whereField("uid", isEqualTo: self.authManager.user.uid)
                                .whereField("deleted", isEqualTo: false)
                                .order(by: "time", descending: true))
        self.listner = query.addSnapshotListener() { (querySnapshot, err) in
            guard let snapshot = querySnapshot else {
                print("ERROR: failed to retrieve bottles in cellar: \(err)")
                return
            }
            var shouldGetProduct: Bool = false
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    let document: QueryDocumentSnapshot = diff.document
                    if !(document.data()["drunk"] as? Bool ?? false) {
                        self.bottleCounts += document.data()["nBottles"] as? Int ?? 1
                    }
                    self.records.append(CellarRecord(document: document))
                    shouldGetProduct = true
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
            if shouldGetProduct {
                self.getProducts()
            }
            else {
                self.loading = false
            }
        }
    }
    
    func getProducts() {
        let pids = self.records.map { record in
            return record.pid
        }
        let language = self.authManager.user.language
        let productCollection = "products_\(String(describing: language))"
        let ref: CollectionReference = Firestore.firestore().collection(productCollection)
        let query: Query = ref.whereField("id", in: pids)
        query.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("ERROR: failed to retrieve products.")
                print(err)
            } else {
                let documents = querySnapshot!.documents
                for document in documents {
                    self.products.append(Product(document: document))
                }
                self.loading.toggle()
                self.sortRecords()
            }
        }
    }
    
    func sortRecords() {
        switch self.sortKey {
        case "latest":
            // sort from newest to oldest
            self.records = self.records.sorted(by: { (lhs: CellarRecord, rhs: CellarRecord) in
                return lhs.time > rhs.time
            })
        case "oldest":
            // sort from oldest to newest
            self.records = self.records.sorted(by: { (lhs: CellarRecord, rhs: CellarRecord) in
                return lhs.time < rhs.time
            })
        case "newest_vintage":
            self.records = self.records.sorted(by: { (lhs: CellarRecord, rhs: CellarRecord) in
                let leftVintage: Int = lhs.vintage ?? 0
                let rightVintage: Int = rhs.vintage ?? 0
                return leftVintage > rightVintage
            })
        case "oldest_vintage":
            self.records = self.records.sorted(by: { (lhs: CellarRecord, rhs: CellarRecord) in
                let leftVintage: Int = lhs.vintage ?? 0
                let rightVintage: Int = rhs.vintage ?? 0
                return leftVintage < rightVintage
            })
        case "average_rating":
            print("sort by average_rating is not implemented, no sorting done.")
        default:
            print("Something went wrong, don't do any sorting here.")
        }
        self.sortProducts()
    }
    
    func sortProducts() {
        var pidAppeared: [String] = []
        var sorted: [Product] = []
        for record in self.records {
            let pid = record.pid
            if !pidAppeared.contains(pid) {
                sorted.append(self.products.first(where: {product in product.id == pid}) ?? Product("unknown"))
                pidAppeared.append(pid)
            }
        }
        self.products = sorted
        self.loading = false
    }
    
    var body: some View {
        List {
            if self.loading { // if data is loaded and sorted
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .onAppear() {
                            self.getRecords()
                        }
                    Spacer()
                }
            }
            else {
                if self.records.isEmpty {
                    // if there is no record in my cellar
                    Text("YOU DON'T HAVE A BOTTLE IN YOUR CELLAR!")
                }
                else {
                    ForEach(self.products, id: \.self) { product in
                        Section {
                            if self.filterKey.isEmpty || self.filterKey.contains(product.type) {
                                ProductRow(product: product,
                                           setNavigationLink: product.id=="unknown" ? false : true)
                                let records: [CellarRecord] = self.records.filter {
                                    $0.pid == product.id
                                }
                                ForEach(records, id: \.self) {record in
                                    CellarRecordRow(record: record)
                                }
                            }
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(
            NSLocalizedString(
                "my_cellar", lang: authManager.user.language),
                displayMode: .inline
        )
        .navigationBarItems(trailing: Button(action: { // sort button
            self.showSortFilterView.toggle()
        }, label: {
            Text(NSLocalizedString("sort_filter", lang: authManager.user.language))
        }))
        .fullScreenCover(isPresented: $showSortFilterView) {
            SortFilterView(show: $showSortFilterView, sortBy: self.$sortKey,
                           sortKeys: self.sortKeys, sort: self.sortRecords,
                           filterBy: self.$filterKey)
        }
        .onDisappear() {
            // maybe don't use this at all or deal with this better
            // don't want to remove when a new view is put on the stack
            // may want to remove when this view is popped
            // self.listner?.remove()
        }
    }
}
