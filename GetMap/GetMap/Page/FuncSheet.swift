//
//  FuncSheet.swift
//  GetMap
//
//  Created by wanruuu on 1/12/2020.
//

import Foundation
import SwiftUI

var clusterNum: Int = 0

struct FuncSheet: View {
    @Binding var showLocations: Bool
    @Binding var showTrajs: Bool
    @Binding var showLineSegs: Bool
    @Binding var showRepresents: Bool
    @Binding var showMap: Bool
    
    @Binding var locations: [Location]
    @Binding var trajectories: [[Coor3D]]
    @Binding var lineSegments: [LineSeg]
    @Binding var representatives: [[Coor3D]]
    @Binding var mapSys: [PathBtwn]
    
    @State var uploadTasks: [Bool] = []
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            Group {
                VStack {
                    Toggle(isOn: $showLocations) { Text("Show Locations") }
                    Toggle(isOn: $showTrajs) { Text("Show Raw Trajectories") }
                    Toggle(isOn: $showLineSegs) { Text("Show Line Segments")}
                    Toggle(isOn: $showRepresents) { Text("Show Representative path") }
                    Toggle(isOn: $showMap) { Text("Show Background map")}
                }
            }.padding()
            Divider()
            Group {
                VStack {
                    Button(action: {
                        /* Step 1: partition */
                        lineSegments = []
                        for traj in trajectories {
                            if(traj.count < 2) {
                                continue
                            }
                            let cp = partition(traj: traj)
                            for index in 0...cp.count-2 {
                                let newLineSeg = LineSeg(start: cp[index], end: cp[index+1], clusterId: 0)
                                lineSegments.append(newLineSeg)
                            }
                        }
                    }) { Text("Partition") }
                    Divider()
                    Button(action: {
                        /* Step 2: cluster */
                        let clusterIds = cluster(lineSegs: lineSegments)
                        clusterNum = 0
                        for i in 0..<lineSegments.count {
                            lineSegments[i].clusterId = clusterIds[i]
                            clusterNum = max(clusterNum, clusterIds[i])
                        }
                    }) { Text("Cluster") }
                    Divider()
                    Button(action: {
                        /* Step 3: generate representative trajectory */
                        representatives = []
                        var clusters = [[LineSeg]](repeating: [], count: clusterNum)
                        for lineSeg in lineSegments {
                            if(lineSeg.clusterId != -1 && lineSeg.clusterId != 0) {
                                clusters[lineSeg.clusterId - 1].append(lineSeg)
                            }
                        }
                        for cluster in clusters {
                            let repTraj = generateRepresent(lineSegs: cluster)
                            if(repTraj.count >= 2) {
                                representatives.append(repTraj)
                            }
                        }
                        representatives = connect(trajs: representatives)
                    }) { Text("Generate representative path") }
                    Divider()
                    Button(action: {
                        /* Step 4: generate map system */
                        let paths = GenerateMapSys(trajs: representatives, locations: locations)
                        for path in paths {
                            mapSys.append(path)
                        }
                    }) { Text("Generate map system") }
                    Divider()
                    Button(action: {
                        /* Step 5: upload map system */
                        uploadTasks = [Bool](repeating: false, count: mapSys.count)
                        for i in 0..<mapSys.count {
                            uploadPath(path: mapSys[i], index: i)
                        }
                        
                    }) { Text("Upload map system") }
                }
            }.padding()
        }
    }
    private func uploadPath(path: PathBtwn, index: Int) {
        /* data */
        let start: [String: Any] = ["name_en": locations[path.startIndex].name_en, "type": locations[path.startIndex].type]
        let end: [String: Any] = ["name_en": locations[path.endIndex].name_en, "type": locations[path.endIndex].type]
        var points: [[String: Any]] = []
        for point in path.points {
            points.append(["latitude": point.latitude, "longitude": point.longitude, "altitude": point.altitude])
        }
        let json: [String: Any] = ["data": ["start": start, "end": end, "path": points, "dist": path.dist, "type": path.type]]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: server + "/path")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { data, response, error in
            if(error != nil) {
                print("error")
            } else {
                guard let data = data else { return }
                do {
                    let res = try JSONDecoder().decode(TrajResponse.self, from: data)
                    if(res.success) {
                        print("success")
                        uploadTasks[index] = true
                    } else {
                        print("error")
                    }
                } catch let error {
                    print(error)
                }
            }
        }.resume()
    }
}
