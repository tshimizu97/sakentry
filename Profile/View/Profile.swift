//
//  Profile.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/02/06.
//

import SwiftUI

struct Profile: View {
    @State var uid: String
    
    init(_ uid: String) {
        self._uid = State(initialValue: uid)
    }
    
    var body: some View {
        Text("PROFILE")
    }
}
