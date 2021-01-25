//
//  Point.swift
//  core
//
//  Created by Bogdan Simon on 22/01/2021.
//  Copyright © 2021 unl. All rights reserved.
//

public class Point: Equatable {
    public let lat: Double;
    public let lon: Double;
    
    init(lat: Double, lon: Double){
        self.lat = lat;
        self.lon = lon;
    }
    
    public static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.lat == rhs.lat && lhs.lon == rhs.lon;
    }
}
