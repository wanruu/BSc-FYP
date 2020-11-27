
import Foundation

struct LocationData {
    var id: Int
    var name_en: String
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var type: Int // 0: building, 1: bus stop
}

var locationData = [
    LocationData(id: 0, name_en: "Art Museum", latitude: 22.419373296469082, longitude: 114.20621694777755, altitude: 93.3248578151688, type: 0),
    LocationData(id: 1, name_en: "Chung Chi Teaching Blocks", latitude: 22.4160229270329, longitude: 114.20832783736773, altitude: 10.92854078207165, type: 1),
    LocationData(id: 2, name_en: "Kuo Mou Hall", latitude: 22.422267809368847, longitude: 114.20109505067131, altitude: 86.67837538011372, type: 0),
    LocationData(id: 3, name_en: "Li Wai Chun Building Halal Food Outlet", latitude: 22.415161267808674, longitude: 114.20719342107641, altitude: 33.75990676879883, type: 0),
    LocationData(id: 4, name_en: "New Asia College (Boarding Point)", latitude: 22.42136616513652, longitude: 114.20745085257104, altitude: 123.00957319699228, type: 1),
    LocationData(id: 5, name_en: "New Asia College (Drop Off Point）", latitude: 22.420903717509855, longitude: 114.20781756132634, altitude: 140.16096118465066, type: 1),
    LocationData(id: 6, name_en: "Residence 3 & 4", latitude: 22.421135250921395, longitude: 114.20349894451265, altitude: 104.04711623117328, type: 1),
    LocationData(id: 7, name_en: "S.H.Ho College", latitude: 22.4180097343796, longitude: 114.20991626742142, altitude: 44.93996192049235, type: 1),
    LocationData(id: 8, name_en: "Shaw College", latitude: 22.422453151060502, longitude: 114.20116173890186, altitude: 84.70719550084323, type: 1),
    LocationData(id: 9, name_en: "Sir Run Run Shaw Hall", latitude: 22.41987559831239, longitude: 114.20704447866856, altitude: 100.54648585058749, type: 1),
    LocationData(id: 10, name_en: "Sui Loong Pao Building", latitude: 22.419655583028167, longitude: 114.20581656737903, altitude: 97.53384460229427, type: 0),
    LocationData(id: 11, name_en: "Train Station", latitude: 22.414435323073562, longitude: 114.21013580995536, altitude: 3.794204492121935, type: 1),
    LocationData(id: 12, name_en: "United College", latitude: 22.420343235363845, longitude: 114.20532619112304, altitude: 125.38025171961635, type: 1),
    LocationData(id: 13, name_en: "University Sport Center", latitude: 22.41779049904475, longitude: 114.21055330015683, altitude: 45.668842003680766, type: 1),
    LocationData(id: 14, name_en: "University Administration Building", latitude: 22.41878610742172, longitude: 114.20527549852746, altitude: 85.80690770503134, type: 1),
    LocationData(id: 15, name_en: "Lo Kwee-Seong Integrated Biomedical Sciences Building", latitude: 22.427611493334734, longitude: 114.20440445130414, altitude: 4.154125954024494, type: 1),
    LocationData(id: 16, name_en: "Pi Ch'iu Building", latitude: 22.419561666098826, longitude: 114.2065255545472, altitude: 98.69729419052601, type: 0),
    LocationData(id: 17, name_en: "Orchid Lodge", latitude: 22.41563141611653, longitude: 114.20785521251639, altitude: 21.845375856384635, type: 0),
    LocationData(id: 18, name_en: "Jockey Club Postgraduate Hall", latitude: 22.420456071675915, longitude: 114.2122480514349, altitude: 24.307415799237788, type: 1)
]
