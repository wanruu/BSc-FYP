//
//  LoadPage.swift
//  GetMap
//
//  Created by wanruuu on 30/11/2020.
//

import Foundation
import SwiftUI

let loadtimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
let dots = [".", "..", "..."]
struct LoadPage: View {
    @Binding var value: Int
    @Binding var total: Int

    @State var index = 0
    var body: some View {
        VStack {
            Image("getmap").resizable().frame(width: 300, height: 150, alignment: .center)
            ProgressView("LOADING\(dots[index])", value: Double(value), total: Double(total))
                .padding(.horizontal, 50)
                .padding(.top)
        }
        .onReceive(loadtimer) { _ in
            if(index == dots.count - 1) {
                index = 0
            } else {
                index += 1
            }
        }
        .padding()
    }
}
