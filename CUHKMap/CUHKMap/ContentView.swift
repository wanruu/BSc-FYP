//
//  ContentView.swift
//  CUHKMap
//
//  Created by wanruuu on 10/10/2020.
//

import SwiftUI
import MapKit

var buildings = [
    /*Building(name: "Academic Building No. 1", coor: [0,0]),
    Building(name: "Academic Building No. 2", coor: [0,0]),
    Building(name: "Adam Schall Residence", coor: [0,0]),
    Building(name: "Art Museum", coor: [0,0]),
    Building(name: "Art Museum Conservation Annex", coor: [0,0]),
    Building(name: "Basic Medical Sciences Building Teaching Annex", coor: [0,0]),
    Building(name: "Benjamin Franklin Centre", coor: [0,0]),
    Building(name: "Bethlehem Hall", coor: [0,0]),
    Building(name: "C.W. Chu College Student Hostel", coor: [0,0]),
    Building(name: "Ch'ien Mu Library - CML", coor: [0,0]),
    Building(name: "Chan Chun Ha Hall", coor: [0,0]),
    Building(name: "Chan Chun Ha Hostel", coor: [0,0]),
    Building(name: "Chan Kwan Tung Inter-University Hall", coor: [0,0]),
    Building(name: "Chen Kou Bun Building - CKB", coor: [0,0]),
    Building(name: "Cheng Ming Building - NAA", coor: [0,0]),
    Building(name: "Cheng Yu Tung Building - CYT", coor: [0,0]),
    Building(name: "Cheung Chuk Shan Amenities Building", coor: [0,0]),
    Building(name: "Chiangs Building (Postgraduate Hall No. 2)", coor: [0,0]),
    Building(name: "Chih Hsing Hall", coor: [0,0]),
    Building(name: "Cho Yiu Conference Hall", coor: [0,0]),
    Building(name: "Choh-Ming Li Basic Medical Sciences Building - BMS", coor: [0,0]),
    Building(name: "Chung Chi College Administration Building", coor: [0,0]),
    Building(name: "Chung Chi College Chapel - CCCC", coor: [0,0]),
    Building(name: "Chung Chi Tang", coor: [0,0]),
    Building(name: "Daisy Li Hall", coor: [0,0]),
    Building(name: "Dorothy and Ti-Hua Koo Building", coor: [0,0]),
    Building(name: "East Wing of the Art Museum - AMEW", coor: [0,0]),
    Building(name: "Elisabeth Luce Moore Library", coor: [0,0]),
    Building(name: "Estates and Maintenance Building Annex", coor: [0,0]),
    Building(name: "Estates Management Office Headquarters", coor: [0,0]),
    Building(name: "Esther Lee Building - ELB", coor: [0,0]),
    Building(name: "Fok Ying Tung Remote Sensing Science Building", coor: [0,0]),
    Building(name: "Fong Shu Chuen Building", coor: [0,0]),
    Building(name: "Fong Yun Wah Hall", coor: [0,0]),
    Building(name: "Friendship Lodge", coor: [0,0]),
    Building(name: "Fung King Hey Building - KHB", coor: [0,0]),
    Building(name: "Grace Tien Hall", coor: [0,0]),
    Building(name: "Hang Seng Hall", coor: [0,0]),
    Building(name: "Ho Sin-Hang Engineering Building - SHB", coor: [0,0]),
    Building(name: "Ho Tim Building - HTB", coor: [0,0]),
    Building(name: "Ho Tim Hall", coor: [0,0]),
    Building(name: "Hong Kong Institute of Biotechnology", coor: [0,0]),
    Building(name: "Hua Lien Tang", coor: [0,0]),
    Building(name: "Huen Wing Ming Building", coor: [0,0]),
    Building(name: "Hui Yeung Shing Building - HYS", coor: [0,0]),
    Building(name: "Humanities Building - NAH", coor: [0,0]),
    Building(name: "Hyatt Regency Hong Kong, Shatin", coor: [0,0]),
    Building(name: "Ina Ho Chan Un Chan Building", coor: [0,0]),
    Building(name: "Institute of Chinese Studies - ICS", coor: [0,0]),
    Building(name: "Inter-University Hall (Postgraduate Hall No.3)", coor: [0,0]),
    Building(name: "International House 1", coor: [0,0]),
    Building(name: "International House 2", coor: [0,0]),
    Building(name: "International House 3", coor: [0,0]),
    Building(name: "Jockey Club Postgraduate Hall 1", coor: [0,0]),
    Building(name: "Jockey Club Postgraduate Hall 2", coor: [0,0]),
    Building(name: "Jockey Club Postgraduate Hall 3", coor: [0,0]),
    Building(name: "John Fulton Centre", coor: [0,0]),
    Building(name: "Kuo Mou Hall (High Block)", coor: [22.422422, 114.200901]),
    Building(name: "Kuo Mou Hall (Low Block)", coor: [22.422679, 114.201244]),
    Building(name: "Kwok Sports Building - KSB", coor: [0,0]),
    Building(name: "Lady Ho Tung Hall", coor: [0,0]),
    Building(name: "Lady Shaw Building - LSB", coor: [0,0]),
    Building(name: "Lee Hysan Concert Hall", coor: [0,0]),
    Building(name: "Lee Quo Wei Hall", coor: [0,0]),
    Building(name: "Lee Shau Kee Architecture Building", coor: [0,0]),
    Building(name: "Lee Shau Kee Building - LSK", coor: [0,0]),
    Building(name: "Lee Shu Pui Hall", coor: [0,0]),
    Building(name: "Lee Woo Sing College North Block", coor: [0,0]),
    Building(name: "Leung Kau Kui Building - KKB", coor: [0,0]),
    Building(name: "Li Dak Sum Building - LDS", coor: [0,0]),
    Building(name: "Li Dak Sum Yip Yio Chin Building", coor: [0,0]),
    Building(name: "Li Wai Chun Building", coor: [0,0]),
    Building(name: "Lingnan Stadium - LN", coor: [0,0]),
    Building(name: "Lo Kwee-Seong Integrated Biomedical Sciences Building", coor: [0,0]),
    Building(name: "Madam S.H. Ho Hall", coor: [0,0]),
    Building(name: "Marina Tse Chu Building", coor: [0,0]),
    Building(name: "Maurice R. Greenberg Building", coor: [0,0]),
    Building(name: "Ming Hua Tang", coor: [0,0]),
    Building(name: "Minor Staff Quarters 1", coor: [0,0]),
    Building(name: "Minor Staff Quarters 2", coor: [0,0]),
    Building(name: "Mong Man Wai Building - MMW", coor: [0,0]),
    Building(name: "Morningside College Student Hostel (High Block)", coor: [0,0]),
    Building(name: "Nissen Huts", coor: [0,0]),
    Building(name: "Orchid Lodge", coor: [0,0]),
    Building(name: "Panacea Lodge", coor: [0,0]),
    Building(name: "Pentecostal Mission Hall Complex (High Block)", coor: [0,0]),
    Building(name: "Pentecostal Mission Hall Complex (Low Block)", coor: [0,0]),
    Building(name: "Physical Geography Experimental Station", coor: [0,0]),
    Building(name: "Pi Ch'iu Building - HCA", coor: [0,0]),
    Building(name: "Pommerenke Student Centre", coor: [0,0]),
    Building(name: "Postgraduate Hall No. 4", coor: [0,0]),
    Building(name: "Postgraduate Hall No. 5", coor: [0,0]),
    Building(name: "Postgraduate Hall No. 6", coor: [0,0]),
    Building(name: "President Chi-tung Yung Memorial Building", coor: [0,0]),
    Building(name: "Run Run Shaw Science Building", coor: [0,0]),
    Building(name: "Satellite Remote Sensing Receiving Station", coor: [0,0]),
    Building(name: "Satellite Remote Sensing Receiving Station", coor: [0,0]),
    Building(name: "Science Centre East Block - SCE", coor: [0,0]),
    Building(name: "Security and Transport Building", coor: [0,0]),
    Building(name: "Shanghai Fraternity Association Research Services Centre", coor: [0,0]),
    Building(name: "Shaw College Lecture Theatre - SWC LT", coor: [22.422380, 114.201568]),
    Building(name: "Shaw College Student Hostel 2 (Low Block)", coor : [22.423776, 114.201011]),
    Building(name: "Si Yuan Amphitheatre", coor: [0,0]),
    Building(name: "Simon F.S. Li Marine Science Laboratory Simon F.S. Li Building", coor: [0,0]),
    Building(name: "Sino Building - SB", coor: [0,0]),
    Building(name: "Sir Run Run Shaw Hall - RRS", coor: [0,0]),
    Building(name: "Sports Field Annex 1", coor: [0,0]),
    Building(name: "Staff Club", coor: [0,0]),
    Building(name: "Staff Quarters A", coor: [0,0]),
    Building(name: "Staff Quarters B", coor: [0,0]),
    Building(name: "Staff Quarters C", coor: [0,0]),
    Building(name: "Staff Quarters D", coor: [0,0]),
    Building(name: "Staff Quarters E", coor: [0,0]),
    Building(name: "Staff Quarters G", coor: [0,0]),
    Building(name: "Staff Quarters S", coor: [0,0]),
    Building(name: "Staff Student Centre - Leung Hung Kee Building", coor: [0,0]),
    Building(name: "Sui Loong Pao Building", coor: [0,0]),
    Building(name: "T.C. Cheng Building - UCC", coor: [0,0]),
    Building(name: "Theology Building - CCT", coor: [0,0]),
    Building(name: "Tin Ka Ping Building", coor: [0,0]),
    Building(name: "Tsang Shiu Tim Building - UCA", coor: [0,0]),
    Building(name: "U.C. Staff Residence", coor: [0,0]),
    Building(name: "United College Wu Chung Library", coor: [0,0]),
    Building(name: "University Administration Building", coor: [0,0]),
    Building(name: "University Health Centre", coor: [0,0]),
    Building(name: "University Library", coor: [0,0]),
    Building(name: "University Residence No. 10", coor: [0,0]),
    Building(name: "University Residence No. 11", coor: [0,0]),
    Building(name: "University Residence No. 12", coor: [0,0]),
    Building(name: "University Residence No. 13", coor: [0,0]),
    Building(name: "University Residence No. 14", coor: [0,0]),
    Building(name: "University Residence No. 15", coor: [0,0]),
    Building(name: "University Residence No. 16", coor: [0,0]),
    Building(name: "University Residence No. 17", coor: [0,0]),
    Building(name: "University Residence No. 3", coor: [0,0]),
    Building(name: "University Residence No. 4", coor: [0,0]),
    Building(name: "University Science Centre - SC", coor: [0,0]),
    Building(name: "University Sports Centre", coor: [0,0]),
    Building(name: "Vice-Chancellor's Residence", coor: [0,0]),
    Building(name: "Water Sports Centre", coor: [0,0]),
    Building(name: "Wen Chih Tang", coor: [0,0]),*/
    Building(name: "Wen Lan Tang - WLS", coor: [22.423150, 114.201700]),
    /*Building(name: "Wen Lin Tang", coor: [0,0]),
    Building(name: "West Wing of the Art Museum", coor: [0,0]),
    Building(name: "William M.W. Mong Engineering Building - ERB", coor: [0,0]),
    Building(name: "Wong Foo Yuan Building - FYB", coor: [0,0]),
    Building(name: "Wu Ho Man Yuen Building - WMY", coor: [0,0]),
    Building(name: "Wu Yee Sun College Activity Centre", coor: [0,0]),
    Building(name: "Wu Yee Sun College Student Hostel East Block", coor: [0,0]),
    Building(name: "Wu Yee Sun College Student Hostel West Block", coor: [0,0]),
    Building(name: "Xuesi Hall", coor: [0,0]),
    Building(name: "Y.C. Liang Hall - LHC", coor: [0,0]),*/
    Building(name: "Ya Qun Lodge", coor: [22.422883, 114.201948]),
    /*Building(name: "Yali Guest House", coor: [0,0]),
    Building(name: "Yasumoto International Academic Park - YIA", coor: [0,0]),
    Building(name: "Yat Sen Hall", coor: [22.423239, 114.201196]),
    Building(name: "Ying Lin Tan", coor: [0,0])*/
]

struct Building{
    var name: String
    var coor: Array<Double>
}

/* all content */
struct ContentView: View {
    /* starting point and destination of a navigation */
    @State var start: String
    @State var coor_start: Array<Double>
    @State var dest: String
    @State var coor_dest: Array<Double>
    /* whether in search page or not.
     0: not;
     1: search for starting point;
     2: search for destination
     */
    @State var show_list: Int
    var body: some View {
        /* Map Page */
        if(show_list == 0) {
            VStack {
                HStack {
                    VStack {
                        // Starting point
                        TextField( "From", text: $start, onEditingChanged: { _ in show_list = 1 } )
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        // destination
                        TextField( "To", text: $dest, onEditingChanged: { _ in show_list = 2 } )
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    // search button
                    Button(action: { }) { Text("Search") }
                        .padding()
                        .border(Color.gray, width: 0.5)
                }
                    .padding(.horizontal)
                
                // map
                MapView(start: start, coor_start: coor_start , dest: dest, coor_dest: coor_dest)
            }
        }
        /* Search Page */
        else if (show_list == 1){
            VStack {
                TextField(
                    "From",
                    text: $start,
                    onCommit: { show_list = 0 }
                )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .padding(.top)
                List {
                    ForEach(0 ..< buildings.count) { value in
                        Button(action: {
                            start = buildings[value].name
                            coor_start = buildings[value].coor
                            show_list = 0
                        } ){ Text(buildings[value].name) }
                    }
                }
            }
        } else {
            VStack {
                TextField(
                    "To",
                    text: $dest,
                    onCommit: { show_list = 0 }
                )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .padding(.top)
                List {
                    ForEach(0 ..< buildings.count) { value in
                        Button(action: {
                            dest = buildings[value].name
                            coor_dest = buildings[value].coor
                            show_list = 0
                        } ){ Text(buildings[value].name) }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(start: "", coor_start: [0, 0], dest: "", coor_dest: [0, 0], show_list: 0)
    }
}


