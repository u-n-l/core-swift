//
//  Elevation.swift
//  core
//
//  Created by Bogdan Simon on 22/01/2021.
//  Copyright © 2021 unl. All rights reserved.
//

public class Elevation: Equatable {
    public let elevation: Int;
    public let elevationType: String;
    
    public init(elevation: Int, elevationType: String){
        self.elevation = elevation;
        self.elevationType = elevationType;
    }
    
    public convenience init(elevation: Int){
        self.init(elevation: elevation, elevationType: "floor");
    }
    
    public static func == (lhs: Elevation, rhs: Elevation) -> Bool {
        return lhs.elevation == rhs.elevation && lhs.elevationType == rhs.elevationType;
    }
}
