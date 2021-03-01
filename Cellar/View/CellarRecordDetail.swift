//
//  CellarRecordDetail.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/02/06.
//

import Firebase
import SwiftUI

struct CellarRecordDetail: View {
    @State var image: UIImage?
    
    let record: CellarRecord
    
    func getImage(){
        if let imageURL = self.record.imageURL {
            let storage = Storage.storage()
            let storageRef = storage.reference(withPath: imageURL)
            storageRef.getData(maxSize: 1 * 1024 * 1024) { data, err in
                if let err = err {
                    print("Something went wrong in loading an image of a bottle")
                    print(err)
                } else {
                    if let data = data {
                        self.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    var body: some View {
        if let image = self.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 60)
        }
        else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 60)
                .onAppear() {
                    self.getImage()
                }
        }
    }
}
