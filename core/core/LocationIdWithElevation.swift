//
//  LocationIdWithElevation.swift
//  core
//
//  Created by Bogdan Simon on 22/01/2021.
//  Copyright © 2021 unl. All rights reserved.
//

public class LocationIdWithElevation: Equatable {
    public let locationId: String;
    public let elevation: Elevation;
    
    init(locationId: String, elevation: Elevation){
        self.locationId = locationId;
        self.elevation = elevation;
    }
    
    public static func == (lhs: LocationIdWithElevation, rhs: LocationIdWithElevation) -> Bool {
        return lhs.locationId == rhs.locationId && lhs.elevation == rhs.elevation;
    }
}
