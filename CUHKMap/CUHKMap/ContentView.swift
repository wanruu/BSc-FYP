//
//  ContentView.swift
//  CUHKMap
//
//  Created by wanruuu on 10/10/2020.
//

import SwiftUI
import MapKit

var buildings = [
    Building(name: "Academic Building No. 1"),
    Building(name: "Academic Building No. 2"),
    Building(name: "Adam Schall Residence"),
    Building(name: "Art Museum"),
    Building(name: "Art Museum Conservation Annex"),
    Building(name: "Basic Medical Sciences Building Teaching Annex"),
    Building(name: "Benjamin Franklin Centre"),
    Building(name: "Bethlehem Hall"),
    Building(name: "C.W. Chu College Student Hostel"),
    Building(name: "Ch'ien Mu Library - CML"),
    Building(name: "Chan Chun Ha Hall"),
    Building(name: "Chan Chun Ha Hostel"),
    Building(name: "Chan Kwan Tung Inter-University Hall"),
    Building(name: "Chen Kou Bun Building - CKB"),
    Building(name: "Cheng Ming Building - NAA"),
    Building(name: "Cheng Yu Tung Building - CYT"),
    Building(name: "Cheung Chuk Shan Amenities Building"),
    Building(name: "Chiangs Building (Postgraduate Hall No. 2)"),
    Building(name: "Chih Hsing Hall"),
    Building(name: "Cho Yiu Conference Hall"),
    Building(name: "Choh-Ming Li Basic Medical Sciences Building - BMS"),
    Building(name: "Chung Chi College Administration Building"),
    Building(name: "Chung Chi College Chapel - CCCC"),
    Building(name: "Chung Chi Tang"),
    Building(name: "Daisy Li Hall"),
    Building(name: "Dorothy and Ti-Hua Koo Building"),
    Building(name: "East Wing of the Art Museum - AMEW"),
    Building(name: "Elisabeth Luce Moore Library"),
    Building(name: "Estates and Maintenance Building Annex"),
    Building(name: "Estates Management Office Headquarters"),
    Building(name: "Esther Lee Building - ELB"),
    Building(name: "Fok Ying Tung Remote Sensing Science Building"),
    Building(name: "Fong Shu Chuen Building"),
    Building(name: "Fong Yun Wah Hall"),
    Building(name: "Friendship Lodge"),
    Building(name: "Fung King Hey Building - KHB"),
    Building(name: "Grace Tien Hall"),
    Building(name: "Hang Seng Hall"),
    Building(name: "Ho Sin-Hang Engineering Building - SHB"),
    Building(name: "Ho Tim Building - HTB"),
    Building(name: "Ho Tim Hall"),
    Building(name: "Hong Kong Institute of Biotechnology"),
    Building(name: "Hua Lien Tang"),
    Building(name: "Huen Wing Ming Building"),
    Building(name: "Hui Yeung Shing Building - HYS"),
    Building(name: "Humanities Building - NAH"),
    Building(name: "Hyatt Regency Hong Kong, Shatin"),
    Building(name: "Ina Ho Chan Un Chan Building"),
    Building(name: "Institute of Chinese Studies - ICS"),
    Building(name: "Inter-University Hall (Postgraduate Hall No.3)"),
    Building(name: "International House 1"),
    Building(name: "International House 2"),
    Building(name: "International House 3"),
    Building(name: "Jockey Club Postgraduate Hall 1"),
    Building(name: "Jockey Club Postgraduate Hall 2"),
    Building(name: "Jockey Club Postgraduate Hall 3"),
    Building(name: "John Fulton Centre"),
    Building(name: "Kuo Mou Hall (High Block)"),
    Building(name: "Kuo Mou Hall (Low Block)"),
    Building(name: "Kwok Sports Building - KSB"),
    Building(name: "Lady Ho Tung Hall"),
    Building(name: "Lady Shaw Building - LSB"),
    Building(name: "Lee Hysan Concert Hall"),
    Building(name: "Lee Quo Wei Hall"),
    Building(name: "Lee Shau Kee Architecture Building"),
    Building(name: "Lee Shau Kee Building - LSK"),
    Building(name: "Lee Shu Pui Hall"),
    Building(name: "Lee Woo Sing College North Block"),
    Building(name: "Leung Kau Kui Building - KKB"),
    Building(name: "Li Dak Sum Building - LDS"),
    Building(name: "Li Dak Sum Yip Yio Chin Building"),
    Building(name: "Li Wai Chun Building"),
    Building(name: "Lingnan Stadium - LN"),
    Building(name: "Lo Kwee-Seong Integrated Biomedical Sciences Building"),
    Building(name: "Madam S.H. Ho Hall"),
    Building(name: "Marina Tse Chu Building"),
    Building(name: "Maurice R. Greenberg Building"),
    Building(name: "Ming Hua Tang"),
    Building(name: "Minor Staff Quarters 1"),
    Building(name: "Minor Staff Quarters 2"),
    Building(name: "Mong Man Wai Building - MMW"),
    Building(name: "Morningside College Student Hostel (High Block)"),
    Building(name: "Nissen Huts"),
    Building(name: "Orchid Lodge"),
    Building(name: "Panacea Lodge"),
    Building(name: "Pentecostal Mission Hall Complex (High Block)"),
    Building(name: "Pentecostal Mission Hall Complex (Low Block)"),
    Building(name: "Physical Geography Experimental Station"),
    Building(name: "Pi Ch'iu Building - HCA"),
    Building(name: "Pommerenke Student Centre"),
    Building(name: "Postgraduate Hall No. 4"),
    Building(name: "Postgraduate Hall No. 5"),
    Building(name: "Postgraduate Hall No. 6"),
    Building(name: "President Chi-tung Yung Memorial Building"),
    Building(name: "Run Run Shaw Science Building"),
    Building(name: "Satellite Remote Sensing Receiving Station"),
    Building(name: "Satellite Remote Sensing Receiving Station"),
    Building(name: "Science Centre East Block - SCE"),
    Building(name: "Security and Transport Building"),
    Building(name: "Shanghai Fraternity Association Research Services Centre"),
    Building(name: "Shaw College Lecture Theatre - SWC LT"),
    Building(name: "Shaw College Student Hostel 2 (Low Block)"),
    Building(name: "Si Yuan Amphitheatre"),
    Building(name: "Simon F.S. Li Marine Science Laboratory Simon F.S. Li Building"),
    Building(name: "Sino Building - SB"),
    Building(name: "Sir Run Run Shaw Hall - RRS"),
    Building(name: "Sports Field Annex 1"),
    Building(name: "Staff Club"),
    Building(name: "Staff Quarters A"),
    Building(name: "Staff Quarters B"),
    Building(name: "Staff Quarters C"),
    Building(name: "Staff Quarters D"),
    Building(name: "Staff Quarters E"),
    Building(name: "Staff Quarters G"),
    Building(name: "Staff Quarters S"),
    Building(name: "Staff Student Centre - Leung Hung Kee Building"),
    Building(name: "Sui Loong Pao Building"),
    Building(name: "T.C. Cheng Building - UCC"),
    Building(name: "Theology Building - CCT"),
    Building(name: "Tin Ka Ping Building"),
    Building(name: "Tsang Shiu Tim Building - UCA"),
    Building(name: "U.C. Staff Residence"),
    Building(name: "United College Wu Chung Library"),
    Building(name: "University Administration Building"),
    Building(name: "University Health Centre"),
    Building(name: "University Library"),
    Building(name: "University Residence No. 10"),
    Building(name: "University Residence No. 11"),
    Building(name: "University Residence No. 12"),
    Building(name: "University Residence No. 13"),
    Building(name: "University Residence No. 14"),
    Building(name: "University Residence No. 15"),
    Building(name: "University Residence No. 16"),
    Building(name: "University Residence No. 17"),
    Building(name: "University Residence No. 3"),
    Building(name: "University Residence No. 4"),
    Building(name: "University Science Centre - SC"),
    Building(name: "University Sports Centre"),
    Building(name: "Vice-Chancellor's Residence"),
    Building(name: "Water Sports Centre"),
    Building(name: "Wen Chih Tang"),
    Building(name: "Wen Lan Tang - WLS"),
    Building(name: "Wen Lin Tang"),
    Building(name: "West Wing of the Art Museum"),
    Building(name: "William M.W. Mong Engineering Building - ERB"),
    Building(name: "Wong Foo Yuan Building - FYB"),
    Building(name: "Wu Ho Man Yuen Building - WMY"),
    Building(name: "Wu Yee Sun College Activity Centre"),
    Building(name: "Wu Yee Sun College Student Hostel East Block"),
    Building(name: "Wu Yee Sun College Student Hostel West Block"),
    Building(name: "Xuesi Hall"),
    Building(name: "Y.C. Liang Hall - LHC"),
    Building(name: "Ya Qun Lodge"),
    Building(name: "Yali Guest House"),
    Building(name: "Yasumoto International Academic Park - YIA"),
    Building(name: "Yat Sen Hall"),
    Building(name: "Ying Lin Tan")
]

struct Building{
    var name: String
}

/* all content */
struct ContentView: View {
    /* starting point and destination of a navigation */
    @State var start: String
    @State var dest: String
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
                MapView()
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
        ContentView(start: "", dest: "", show_list: 0)
    }
}


