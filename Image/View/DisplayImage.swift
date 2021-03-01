//
//  DisplayImage.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2/15/21.
//

import SwiftUI

struct DisplayImage: View {
    @EnvironmentObject var authManager: AuthManager
    var loading: Binding<Bool>?
    let image: UIImage?
    let width: CGFloat
    let height: CGFloat?
    let text: String
    let onAppear: ()->Void
    
    init(_ image: UIImage?, widthScale: Double, hToW: Double?=nil, geo: GeometryProxy, onAppear: (()->Void)?=nil, loading: Binding<Bool>?=nil, text: String="") {
        self.image = image
        self.width = geo.size.width * CGFloat(widthScale)
        if let hToW = hToW {
            self.height = geo.size.width * CGFloat(widthScale) * CGFloat(hToW)
        } else {
            self.height = nil
        }
        self.text = text
        if let onAppear = onAppear {
            self.onAppear = onAppear
        } else {
            self.onAppear = {}
        }
        self.loading = loading
    }
    
    var body: some View {
        if self.loading?.wrappedValue ?? false {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .frame(width: self.width, height: self.height)
                .onAppear() {
                    self.onAppear()
                }
        } else {
            if let image = self.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: self.width, height: self.height)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .frame(width: self.width,
                           height: self.height)
                    .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
                    .overlay(Text(NSLocalizedString(self.text, lang: authManager.user.language))
                                .font(.caption)
                                .padding(),
                             alignment: .bottom)
            }
        }
    }
}
