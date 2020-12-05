//
//  MapPage.swift
//  CUMap
//
//  Created by wanruuu on 5/12/2020.
//

import Foundation
import SwiftUI

struct MapPage: View {
    @Binding var locations: [Location]
    @Binding var paths: [PathBtwn]
    @ObservedObject var locationGetter: LocationGetterModel
    
    /* search keyword */
    @State var start: String = ""
    @State var end: String = ""
    @State var showStartSearch: Bool = false
    @State var showEndSearch: Bool = false
    
    /* search result */
    @State var result: [Coor3D] = []
    
    var body: some View {
        ZStack(alignment: .bottom) {
            MapView(result: $result)
            VStack {
                // search input area
                HStack {
                    VStack {
                        HStack {
                            showEndSearch ? nil : TextField("From", text: $start, onEditingChanged: { _ in })
                                .onTapGesture {
                                    start = ""
                                    showStartSearch = true
                                    showEndSearch = false
                                }.textFieldStyle(RoundedBorderTextFieldStyle())
                            showStartSearch ? Button(action: {
                                showStartSearch = false
                                hideKeyboard()
                            }) { Text("Cancel")}.background(Color.white) : nil
                        }
                        HStack {
                            showStartSearch ? nil : TextField("To", text: $end, onEditingChanged: { _ in })
                                .onTapGesture {
                                    end = ""
                                    showEndSearch = true
                                    showStartSearch = false
                                }.textFieldStyle(RoundedBorderTextFieldStyle())
                            showEndSearch ? Button(action: {
                                showEndSearch = false
                                hideKeyboard()
                            }) { Text("Cancel")}.background(Color.white) : nil
                        }
                        
                    }
                    showStartSearch || showEndSearch ? nil : Button(action: {
                        for path in paths {
                            if((path.start.name_en == start && path.end.name_en == end) || (path.start.name_en == end && path.end.name_en == start)) {
                                result = path.path
                            }
                        }
                    }) {Text("Search")}.background(Color.white)
                }
                // search result
                showStartSearch ? List {
                    ForEach(0 ..< locations.count) { index in
                        start == "" || locations[index].name_en.lowercased().contains(start.lowercased()) ?
                            Button(action: {
                                start = locations[index].name_en
                                showStartSearch = false
                                hideKeyboard()
                            }){ Text(locations[index].name_en) } : nil
                    }
                } : nil
                showEndSearch ? List {
                    ForEach(0 ..< locations.count) { index in
                        end == "" || locations[index].name_en.lowercased().contains(end.lowercased()) ?
                            Button(action: {
                                end = locations[index].name_en
                                showEndSearch = false
                                hideKeyboard()
                            } ){ Text(locations[index].name_en) } : nil
                    }
                } : nil
                
                Spacer()
            }.padding()
        }
    }
}

struct MapView: View {
    @Binding var result: [Coor3D]
    
    /* gesture */
    @State var lastOffset = Offset(x: 0, y: 0)
    @State var offset = Offset(x: 0, y: 0)
    @State var lastScale = minZoomOut
    @State var scale = minZoomOut
    
    var body: some View {
        ZStack {
            Image("cuhk-campus-map")
                .resizable()
                .frame(width: 3200 * scale, height: 3200 * 25 / 20 * scale, alignment: .center)
                .position(x: centerX + offset.x, y: centerY + offset.y)
            ResultView(path: $result, offset: $offset, scale: $scale)
        }
        .contentShape(Rectangle())
        .gesture(
            SimultaneousGesture(
                MagnificationGesture()
                    .onChanged { value in
                        var tmpScale = lastScale * value.magnitude
                        if(tmpScale < minZoomOut) {
                            tmpScale = minZoomOut
                        } else if(tmpScale > maxZoomIn) {
                            tmpScale = maxZoomIn
                        }
                        scale = tmpScale
                        offset = lastOffset * tmpScale / lastScale
                    }
                    .onEnded { _ in
                        lastScale = scale
                        lastOffset.x = offset.x
                        lastOffset.y = offset.y
                    },
                DragGesture()
                    .onChanged{ value in
                        offset.x = lastOffset.x + value.location.x - value.startLocation.x
                        offset.y = lastOffset.y + value.location.y - value.startLocation.y
                        
                    }
                    .onEnded{ _ in
                        lastOffset.x = offset.x
                        lastOffset.y = offset.y
                    }
            )
        )
    }
}

struct ResultView: View {
    @Binding var path: [Coor3D]
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    var body: some View {
        Path { p in
            for i in 0..<path.count {
                let point = CGPoint(
                    x: centerX + CGFloat((path[i].longitude - centerLg)*lgScale*2) * scale + offset.x,
                    y: centerY + CGFloat((centerLa - path[i].latitude)*laScale*2) * scale + offset.y
                )
                if(i == 0) {
                    p.move(to: point)
                } else {
                    p.addLine(to: point)
                }
            }
        }.stroke(Color.blue, style: StrokeStyle(lineWidth: 5, lineJoin: .round))
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
