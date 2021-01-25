//
//  BoundsWithElevation.swift
//  core
//
//  Created by Bogdan Simon on 22/01/2021.
//  Copyright © 2021 unl. All rights reserved.
//

public class BoundsWithElevation: Equatable {
    public let bounds: Bounds;
    public let elevation: Elevation;
    
    init(bounds: Bounds, elevation: Elevation){
        self.bounds = bounds;
        self.elevation = elevation;
    }
    
    public static func == (lhs: BoundsWithElevation, rhs: BoundsWithElevation) -> Bool {
        return lhs.bounds == rhs.bounds && lhs.elevation == rhs.elevation;
    }
}
