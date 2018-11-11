
import Foundation

struct CityDistanceBasicInfo: Codable {
    let title, locationType: String
    let distance, woeid: Int
    let lattLong: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case locationType = "location_type"
        case woeid
        case distance
        case lattLong = "latt_long"
    }
}
