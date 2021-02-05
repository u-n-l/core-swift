//
//  Point.swift
//  core
//
//  Created by Bogdan Simon on 22/01/2021.
//  Copyright © 2021 unl. All rights reserved.
//

public class Point: Equatable, Decodable {
    public let lat: Double;
    public let lon: Double;
    
    public init(lat: Double, lon: Double){
        self.lat = lat;
        self.lon = lon;
    }
    
    enum CodingKeys: String, CodingKey {
        case lat = "lat"
        case lon = "lon"
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self);
        
        lat = try values.decode(Double.self, forKey: CodingKeys.lat)
        lon = try values.decode(Double.self, forKey: CodingKeys.lon)
    }
    
    public static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.lat == rhs.lat && lhs.lon == rhs.lon;
    }
}
