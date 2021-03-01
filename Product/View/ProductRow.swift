//
//  ProductRow.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/06.
//

import Firebase
import SwiftUI

struct ProductRow: View {
    @EnvironmentObject var authManager: AuthManager
    let product: Product
    @State var setNavigationLink: Bool
    
    @State var clicked: Bool = false
    @State var loading: Bool = true
    @State var image: UIImage?
    var img_path: String? {
        if let img_urls = self.product.img_urls {
            let img_url = img_urls[0]
            if let filename: String = img_url.components(separatedBy: "/").last {
                return "\(NSHomeDirectory())/tmp/\(product.id)_\(filename)"
            }
        }
        return nil
    }
    
    init(product: Product, setNavigationLink: Bool=true) {
        self.product = product
        self._setNavigationLink = State(initialValue: setNavigationLink)
    }
    
    func getImage(){ // call this method only when self.product.img_urls exist
        if let img_urls = self.product.img_urls {
            let img_url = img_urls[0]
            let storage = Storage.storage()
            let storageRef = storage.reference(withPath: img_url)
            storageRef.getData(maxSize: 1 * 1024 * 1024) { data, err in
                if let err = err {
                    print("Something went wrong in downloading data: \(err)")
                } else {
                    if let data = data {
                        self.image = UIImage(data: data)
                        if let img_path = self.img_path {
                            do {
                                try data.write(to: URL(fileURLWithPath: img_path))
                            }
                            catch {
                                print("ERROR: failed to save a product image.")
                                print(error)
                            }
                        }
                    }
                }
                self.loading =  false
            }
        }
    }
    
    var body: some View {
        HStack {
            if self.loading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(width: 80, height: 120)
            }
            else {
                if let image: UIImage = self.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 120)
                }
                else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 120)
                }
            }
            VStack(alignment: .leading) { // basic info
                Text(product.brand)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(product.name)
                    .font(.title)
                    .foregroundColor(.primary)
                Text("\(NSLocalizedString(product.type, lang: authManager.user.language)) from \(NSLocalizedString(product.city, lang: authManager.user.language)), \(NSLocalizedString(product.prefecture, lang: authManager.user.language))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .onAppear() {
            if let img_path = self.img_path {
                if FileManager.default.fileExists(atPath: img_path) {
                    // load image from local storage
                    do {
                        let data: Data = try Data(contentsOf: URL(fileURLWithPath: img_path))
                        self.image = UIImage(data: data)
                        self.loading = false
                    }
                    catch {
                        print("Failed in loading product image; call API instead.")
                        self.getImage()
                    }
                }
                else {
                    self.getImage()
                }
            }
            else {
                self.loading = false
            }
        }
        .onTapGesture {
            if (self.setNavigationLink) {
                self.clicked.toggle()
            }
        }
        .background(
            NavigationLink(destination: ProductDetail(product: product, image: $image),
                           isActive: self.$clicked) {EmptyView()}
                .disabled(!self.setNavigationLink)
        )
    }
}
