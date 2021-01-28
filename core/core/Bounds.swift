//
//  Bounds.swift
//  core
//
//  Created by Bogdan Simon on 22/01/2021.
//  Copyright © 2021 unl. All rights reserved.
//

public class Bounds: Equatable, Decodable {
    public let sw: Point;
    public let ne: Point;
    
    init(sw: Point, ne: Point){
        self.sw = sw;
        self.ne = ne;
    }
    
    enum CodingKeys: String, CodingKey {
        case sw = "sw"
        case ne = "ne"
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self);
        
        sw = try values.decode(Point.self, forKey: CodingKeys.sw)
        ne = try values.decode(Point.self, forKey: CodingKeys.ne)
    }
    
    public static func == (lhs: Bounds, rhs: Bounds) -> Bool {
        return lhs.sw == rhs.sw && lhs.ne == rhs.ne;
    }
}
