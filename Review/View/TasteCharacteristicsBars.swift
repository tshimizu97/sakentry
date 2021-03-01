//
//  TasteCharacteristicsBars.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/31.
//

import SwiftUI

struct TasteCharacteristicsBars: View {
    @EnvironmentObject var authManager: AuthManager
    
    let tasteValueMax: Double
    let taste_characteristics: [[String]]
    @Binding var tasteValues: [Double]
    @Binding var valueDisabled: [Bool]
    
    var body: some View {
        VStack {
            Text(NSLocalizedString("add taste characteristics", lang: authManager.user.language))
            ForEach(0..<taste_characteristics.count) { i in // taste characteristics bars
                let taste: [String] = taste_characteristics[i]
                HStack {
                    HStack { // slide bar
                        Spacer()
                        Text(NSLocalizedString(taste[0])).font(.caption)
                        Slider(value: self.$tasteValues[i],
                               in: 0...self.tasteValueMax, step: 1) {
                            Text(NSLocalizedString(taste[2]))
                        }
                        .frame(width: 200)
                        Text(NSLocalizedString(taste[1])).font(.caption)
                        Spacer()
                    }
                    .opacity(self.valueDisabled[i] ? 0.3 : 1)
                    .disabled(self.valueDisabled[i])
                    Button(action: { // disable button
                        self.valueDisabled[i].toggle()
                    }) {
                        if self.valueDisabled[i] {
                            Text(NSLocalizedString("enable", lang: authManager.user.language))
                        }
                        else {
                            Text(NSLocalizedString("disable", lang: authManager.user.language))
                        }
                    }
                }
            }
        }
        .padding()
        .border(Color.gray)
    }
}
