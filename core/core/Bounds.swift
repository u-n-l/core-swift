//
//  Bounds.swift
//  core
//
//  Created by Bogdan Simon on 22/01/2021.
//  Copyright © 2021 unl. All rights reserved.
//

public class Bounds: Equatable {
    public let sw: Point;
    public let ne: Point;
    
    init(sw: Point, ne: Point){
        self.sw = sw;
        self.ne = ne;
    }
    
    public static func == (lhs: Bounds, rhs: Bounds) -> Bool {
        return lhs.sw == rhs.sw && lhs.ne == rhs.ne;
    }
}
