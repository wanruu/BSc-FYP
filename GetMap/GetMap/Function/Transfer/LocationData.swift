//
//  LocationData.swift
//  GetMap
//
//  Created by wanruuu on 27/11/2020.
//

import Foundation

func loadLocationData() {//-> [Location] {
    let url = URL(string: "http://10.13.115.254:8000/locations")!
    let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
        guard let data = data else { return }
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        print(json)
    }
    task.resume()
}
