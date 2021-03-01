//
//  UploadImageView.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2/10/21.
//

import SwiftUI

struct UploadImageView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var image: UIImage?
    let widthScale: CGFloat
    let hToW: CGFloat
    let geo: GeometryProxy
    let text: String
    
    @State var showActionSheet: Bool = false
    @State var useCamera: Bool = false
    @State var showImagePicker: Bool = false
    
    init(_ image: Binding<UIImage?>, widthScale: Double, hToW: Double, geo: GeometryProxy, text: String="") {
        self._image = image
        self.widthScale = CGFloat(widthScale)
        self.hToW = CGFloat(hToW)
        self.geo = geo
        self.text = text
    }
    
    @ViewBuilder func getImageView() -> some View {
        if let image = self.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: self.geo.size.width * self.widthScale,
                       height: self.geo.size.width * self.widthScale * self.hToW)
                .foregroundColor(Color.black)
        }
        else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .padding()
                .frame(width: self.geo.size.width * self.widthScale,
                       height: self.geo.size.width * self.widthScale * self.hToW)
                .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
                .overlay(Text(NSLocalizedString(self.text, lang: authManager.user.language))
                            .font(.caption)
                            .padding(),
                         alignment: .bottom)
                .foregroundColor(Color.black)
        }
    }
    
    var body: some View {
        Button(action: { // image
            self.showActionSheet.toggle()
        }) {
            self.getImageView()
        }
        .actionSheet(isPresented: $showActionSheet) { // action sheet
            ActionSheet(
                title: Text(NSLocalizedString("choose method",
                                              lang: authManager.user.language)),
                message: Text(NSLocalizedString("choose how to upload a picture",
                                                lang: authManager.user.language)),
                buttons: [
                    .default(Text("take a new photo"), action: {
                        self.useCamera = true
                        self.showImagePicker.toggle()
                    }),
                    .default(Text("upload from photos"), action: {
                        self.useCamera = false
                        self.showImagePicker.toggle()
                    }),
                    .cancel()
                ])
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerUIView(sourceType: self.useCamera ? .camera : .photoLibrary,
                              image: $image,
                              isPresented: $showImagePicker,
                              hToW: self.hToW)
        }
    }
}
