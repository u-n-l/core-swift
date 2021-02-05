//
//  Bounds.swift
//  core
//
//  Created by Bogdan Simon on 22/01/2021.
//  Copyright © 2021 unl. All rights reserved.
//

public class Bounds: Equatable, Decodable {
    public let n: Double;
    public let e: Double;
    public let s: Double;
    public let w: Double;
    
    init(n: Double, e: Double, s: Double, w: Double){
        self.n = n;
        self.e = e;
        self.s = s;
        self.w = w;
    }
    
    enum CodingKeys: String, CodingKey {
        case n = "n"
        case e = "e"
        case s = "s"
        case w = "w"
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self);
        
        n = try values.decode(Double.self, forKey: CodingKeys.n)
        e = try values.decode(Double.self, forKey: CodingKeys.e)
        s = try values.decode(Double.self, forKey: CodingKeys.s)
        w = try values.decode(Double.self, forKey: CodingKeys.w)
    }
    
    public static func == (lhs: Bounds, rhs: Bounds) -> Bool {
        return lhs.n == rhs.n && lhs.e == rhs.e && lhs.s == rhs.s && lhs.w == rhs.w;
    }
}
