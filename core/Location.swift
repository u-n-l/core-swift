//
//  Location.swift
//  core
//
//  Created by Bogdan Simon on 26/01/2021.
//  Copyright © 2021 unl. All rights reserved.
//

public class Location: Equatable, Decodable {
    public let point: Point;
    public let elevation: Elevation;
    public let bounds: Bounds;
    public let geohash: String;
    public let words: String;
    
    public init(point: Point, elevation: Elevation, bounds: Bounds, geohash: String, words: String){
        self.point = point;
        self.elevation = elevation;
        self.bounds = bounds;
        self.geohash = geohash;
        self.words = words;
    }
    
    enum CodingKeys: String, CodingKey {
        case lat = "lat"
        case lon = "lon"
        case elevation = "elevation"
        case elevationType = "elevationType"
        case geohash = "geohash"
        case words = "words"
        case bounds = "bounds"
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let lat = try values.decode(Double.self, forKey: CodingKeys.lat)
        let lon = try values.decode(Double.self, forKey: CodingKeys.lon)
        let elevation = try values.decode(Int.self, forKey: CodingKeys.elevation);
        let elevationType = try values.decode(String.self, forKey: CodingKeys.elevationType);
        
        point = Point(lat: lat, lon: lon);
        self.elevation = Elevation(elevation: elevation, elevationType: elevationType);
        
        bounds = try values.decode(Bounds.self, forKey: CodingKeys.bounds);
        words = try values.decode(String.self, forKey: CodingKeys.words);
        geohash = try values.decode(String.self, forKey: CodingKeys.geohash);
    }
    
    public static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.point == rhs.point && lhs.elevation == rhs.elevation && lhs.bounds == rhs.bounds && lhs.geohash == rhs.geohash && lhs.words == rhs.words;
    }
}
