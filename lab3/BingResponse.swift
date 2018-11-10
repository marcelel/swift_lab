// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

struct BingResponse: Codable {
    let authenticationResultCode: String
    let brandLogoURI: String
    let copyright: String
    let resourceSets: [ResourceSet]
    let statusCode: Int
    let statusDescription, traceID: String
    
    enum CodingKeys: String, CodingKey {
        case authenticationResultCode
        case brandLogoURI = "brandLogoUri"
        case copyright, resourceSets, statusCode, statusDescription
        case traceID = "traceId"
    }
}

struct ResourceSet: Codable {
    let estimatedTotal: Int
    let resources: [Resource]
}

struct Resource: Codable {
    let type: String
    let bbox: [Double]
    let name: String
    let point: Point
    let address: Address
    let confidence, entityType: String
    let geocodePoints: [GeocodePoint]
    let matchCodes: [String]
    
    enum CodingKeys: String, CodingKey {
        case type = "__type"
        case bbox, name, point, address, confidence, entityType, geocodePoints, matchCodes
    }
}

struct Address: Codable {
    let adminDistrict, adminDistrict2, countryRegion, formattedAddress: String
    let locality: String
}

struct GeocodePoint: Codable {
    let type: String
    let coordinates: [Double]
    let calculationMethod: String
    let usageTypes: [String]
}

struct Point: Codable {
    let type: String
    let coordinates: [Double]
}
