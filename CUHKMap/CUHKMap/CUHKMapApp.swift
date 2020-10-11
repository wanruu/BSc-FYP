//
//  CUHKMapApp.swift
//  CUHKMap
//
//  Created by wanruuu on 10/10/2020.
//

import SwiftUI

@main
struct CUHKMapApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(start: "", coor_start: [0, 0], dest: "", coor_dest: [0, 0], show_list: 0)
        }
    }
}
