//
//  TemperaturePicker.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/31.
//

import SwiftUI

struct TemperaturePicker: View {
    var temperatures: [String]
    @Binding var temperatureBools: [Bool]

    @State private var totalHeight
          = CGFloat.zero       // << variant for ScrollView/List
    //    = CGFloat.infinity   // << variant for VStack

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)// << variant for ScrollView/List
        //.frame(maxHeight: totalHeight) // << variant for VStack
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(0..<self.temperatures.count) { i in
                let temp = temperatures[i]
                self.item(for: temp, idx: i)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if temp == self.temperatures.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if temp == self.temperatures.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }.background(viewHeightReader($totalHeight))
    }

    private func item(for text: String, idx i: Int) -> some View {
        Button(action: {
            temperatureBools[i].toggle()
        }) {
            Text(text)
                .padding(.all, 5)
                .font(.body)
                .background(temperatureBools[i] ? Color.blue : Color.gray)
                .foregroundColor(Color.white)
                .cornerRadius(5)
        }
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}
