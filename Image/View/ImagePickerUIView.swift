//
//  ImagePickerUIView.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/24.
//
// https://medium.com/better-programming/how-to-pick-an-image-from-camera-or-photo-library-in-swiftui-a596a0a2ece

import SwiftUI
import UIKit

struct ImagePickerUIView: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    let hToW: CGFloat
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var image: UIImage?
        @Binding var isPresented: Bool
        let hToW: CGFloat
        
        init(_ image: Binding<UIImage?>, _ isPresented: Binding<Bool>, _ hToW: CGFloat) {
            self._image = image
            self._isPresented = isPresented
            self.hToW = hToW
        }
        
        func modifyImageSize(image: UIImage) -> UIImage? {
            let w: CGFloat = image.size.width
            let h: CGFloat = image.size.height
            let originalAspect: CGFloat = h / w
            var newH: CGFloat
            var newW: CGFloat
            if h > w * self.hToW {
                // use height for resizing
                newH = 400 * self.hToW
                newW = newH / originalAspect
            }
            else { // h <= w * h_to_w
                // use width for resizing
                newW = 400
                newH = newW * originalAspect
            }
            let newSize = CGSize(width: newW, height: newH)
            UIGraphicsBeginImageContext(newSize)
            image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.image = self.modifyImageSize(image: image)
            }
            self.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.isPresented = false
        }
        
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator($image, $isPresented, hToW)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = sourceType
        pickerController.delegate = context.coordinator
        return pickerController
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // do nothing
    }
}

