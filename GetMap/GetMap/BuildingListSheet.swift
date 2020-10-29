//
//  BuildingListSheet.swift
//  GetMap
//
//  Created by wanruuu on 29/10/2020.
//

import Foundation
import SwiftUI

struct BuildingListSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var buildings: FetchedResults<Building>
    var body: some View {
        VStack {
            Text("Building List").padding()
            List {
                ForEach(buildings) { building in
                    VStack(alignment: .leading) {
                        Text(building.name_en).font(.headline)
                        Text("(\(building.latitude), \(building.longitude))").font(.subheadline)
                    }
                }
                .onDelete{ indexSet in
                    for index in indexSet {
                        viewContext.delete(buildings[index])
                    }
                    do {
                        try viewContext.save()
                    } catch {
                        print(error.localizedDescription)
                    }}
            }
        }
    }
}
