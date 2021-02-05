//
//  Neighbour.swift
//  core
//
//  Created by Bogdan Simon on 22/01/2021.
//  Copyright © 2021 unl. All rights reserved.
//

public class Neighbours: Equatable {
    public let n: String;
    public let ne: String;
    public let e: String;
    public let se: String;
    public let s: String;
    public let sw: String;
    public let w: String;
    public let nw: String;
    
    public init(n: String, ne: String, e: String, se: String,s: String, sw: String, w: String, nw: String){
        self.n = n;
        self.ne = ne;
        self.e = e;
        self.se = se;
        self.s = s;
        self.sw = sw;
        self.w = w;
        self.nw = nw;
    };
    
    public static func == (lhs: Neighbours, rhs: Neighbours) -> Bool {
        return lhs.n == rhs.n && lhs.ne == rhs.ne && lhs.e == rhs.e && lhs.se == rhs.se && lhs.s == rhs.s && lhs.sw == rhs.sw && lhs.w == rhs.w && lhs.nw == rhs.nw;
    }
}
