//
//  CosmosUIView.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/24.
// copied from: https://github.com/evgenyneu/Cosmos/wiki/Using-Cosmos-with-SwiftUI

import SwiftUI
import Cosmos

// A SwiftUI wrapper for Cosmos view
struct CosmosUIView: UIViewRepresentable {
    @Binding var rating: Double
    let editable: Bool
    let size: Double
    
    init(rating: Binding<Double>, editable: Bool = true, size: Double) {
        self._rating = rating
        self.editable = editable
        self.size = size
    }

    func makeUIView(context: Context) -> CosmosView {
        let cosmosView = CosmosView()
        // Autoresize Cosmos view according to its intrinsic size
        cosmosView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        cosmosView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        if editable {
            // Change Cosmos view settings here
            cosmosView.settings.starSize = self.size
            cosmosView.settings.fillMode = .half
            
            cosmosView.didFinishTouchingCosmos = { rating in
                self.rating = rating
            }
        }
        
        else {
            // Change Cosmos view settings here
            cosmosView.settings.starSize = self.size
            cosmosView.settings.fillMode = .precise
            cosmosView.settings.updateOnTouch = false
        }
        return cosmosView
    }

    func updateUIView(_ uiView: CosmosView, context: Context) {
        uiView.rating = self.rating
    }
}
