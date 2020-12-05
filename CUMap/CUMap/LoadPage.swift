//
//  LoadPage.swift
//  CUMap
//
//  Created by wanruuu on 5/12/2020.
//

import Foundation
import SwiftUI

let loadtimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
let dots = [".", "..", "..."]

struct LoadPage: View {
    @Binding var tasks: [Bool]

    @State var index = 0 // index for dots
    var body: some View {
        VStack {
            Image("cumap").resizable().frame(width: 300, height: 150, alignment: .center)
            ProgressView("LOADING\(dots[index])", value: Double(tasks.filter{$0 == true}.count), total: Double(tasks.count))
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
