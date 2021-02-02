//
//  PointWithElevation.swift
//  core
//
//  Created by Bogdan Simon on 22/01/2021.
//  Copyright © 2021 unl. All rights reserved.
//

class PointWithElevation: Equatable {
    public let coordinates: Point;
    public let elevation: Elevation;
    public let bounds: BoundsWithElevation;
    
    init(coordinates: Point, elevation: Elevation, bounds: BoundsWithElevation){
        self.coordinates = coordinates;
        self.elevation = elevation;
        self.bounds = bounds;
    };
    
    static func == (lhs: PointWithElevation, rhs: PointWithElevation) -> Bool {
        return lhs.coordinates == rhs.coordinates && lhs.elevation == rhs.elevation && lhs.bounds == rhs.bounds;
    }
}
