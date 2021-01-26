//
//  UnlCore.swift
//  core
//
//  Created by Bogdan Simon on 22/01/2021.
//  Copyright © 2021 unl. All rights reserved.
//

class UnlCore {
    static let instance = UnlCore();
    private static let base32 = "0123456789bcdefghjkmnpqrstuvwxyz";
    public static let defaultElevation = Elevation(elevation: 0, elevationType: "floor");
    public static let defaultPrecision = 9;
    
    init() {}
    
    /**
     Returns the unique instance of the UnlCore class.
     */
    public class func getInstance() -> UnlCore {
        return instance;
    }
    
    func encode(lat: Double, lon: Double, precision: Int, elevation: Elevation) -> String {
        var idx: Int = 0;
        var bit: Int = 0;
        var evenBit: Bool = true;
        var locationId: String = "";
        
        var latMin: Double = -90;
        var latMax: Double = 90;
        var lonMin: Double = -180;
        var lonMax: Double = 180;
        
        while(locationId.count < precision){
            if (evenBit) {
                // bisect E-W longitude
                let lonMid: Double = (lonMin + lonMax) / 2.0;
                
                if (lon >= lonMid) {
                    idx = idx * 2 + 1;
                    lonMin = lonMid;
                } else {
                    idx = idx * 2;
                    lonMax = lonMid;
                }
            } else {
                // bisect N-S latitude
                let latMid: Double = (latMin + latMax) / 2;
                
                if (lat >= latMid) {
                    idx = idx * 2 + 1;
                    latMin = latMid;
                } else {
                    idx = idx * 2;
                    latMax = latMid;
                }
            }
            
            evenBit = !evenBit;
            
            bit += 1;
            if (bit == 5) {
                // 5 bits gives us a character: append it and start over
                locationId.append(UnlCore.base32[UnlCore.base32.index(UnlCore.base32.startIndex, offsetBy: idx)]);
                bit = 0;
                idx = 0;
            }
        }
        
        let elevationNumber: Int = elevation.elevation;
        let elevationType: String = elevation.elevationType;
        let elevationObject: Elevation = Elevation(elevation: elevationNumber, elevationType: elevationType);
        
        return appendElevation(locationIdWithoutElevation: locationId, elevation: elevationObject);
    }
    
    func encode(lat: Double, lon: Double, precision: Int) -> String {
        return encode(lat: lat, lon: lon, precision: precision, elevation: UnlCore.defaultElevation );
    }
    
    func encode(lat: Double, lon: Double, elevation: Elevation) -> String {
        for p in 1..<(UnlCore.defaultPrecision + 1) {
            let hash: String = encode(lat: lat, lon: lon, precision: p);
            let posn: PointWithElevation = decode(locationId: hash);
            
            if(posn.coordinates.lat == lat && posn.coordinates.lon == lon){
                return hash;
            }
        }
        
        return encode(lat: lat, lon: lon, precision: UnlCore.defaultPrecision, elevation: elevation);
    }
    
    func encode(lat: Double, lon: Double) -> String {
        return encode(lat: lat, lon: lon, elevation: UnlCore.defaultElevation);
    }
    
    func decode(locationId: String) -> PointWithElevation {
        let locationIdWithElevation: LocationIdWithElevation = excludeElevation(locationIdWithElevation: locationId);
        let boundsWithElevation: BoundsWithElevation = bounds(locationId: locationIdWithElevation.locationId);
        let bounds: Bounds = boundsWithElevation.bounds;
        
        let latMin: Double = bounds.sw.lat;
        let lonMin: Double = bounds.sw.lon;
        
        let latMax: Double = bounds.ne.lat;
        let lonMax:Double = bounds.ne.lon;
        
        //cell center
        var lat: Double = (latMin + latMax) / 2.0;
        var lon: Double = (lonMin + lonMax) / 2.0;
        
        let latPrecision: Int = Int(floor(2 - log10(latMax - latMin) / log10(10)));
        let lonPrecision: Int = Int(floor(2 - log10(lonMax - lonMin) / log10(10)));
        
        lat = (lat * pow(10.0, Double(latPrecision))).rounded()/pow(10.0, Double(latPrecision));
        lon = (lon * pow(10.0, Double(lonPrecision))).rounded()/pow(10.0, Double(lonPrecision));
        
        let point: Point = Point(lat: lat, lon: lon);
        return PointWithElevation(coordinates: point, elevation: locationIdWithElevation.elevation, bounds: boundsWithElevation);
        
    }
    
    func appendElevation(locationIdWithoutElevation: String, elevation: Elevation) -> String {
        if (elevation.elevation == 0) {
            return locationIdWithoutElevation;
        }
        
        var elevationChar: Character = "@";
        if (elevation.elevationType == "heightincm") {
            elevationChar = "#";
        }
        
        return locationIdWithoutElevation + String(elevationChar) + String(elevation.elevation);
    }
    
    func excludeElevation(locationIdWithElevation: String) -> LocationIdWithElevation {
        var locationIdWithoutElevation: String = locationIdWithElevation.lowercased();
        var elevationType: String = "floor";
        var elevation: Int = 0;
        
        if (locationIdWithElevation.contains("#")) {
            locationIdWithoutElevation =  locationIdWithElevation.components(separatedBy: "#")[0];
            elevation = Int(locationIdWithElevation.components(separatedBy: "#")[1]) ?? 0;
            elevationType = "heightincm";
        }
        
        if (locationIdWithElevation.contains("@")) {
            locationIdWithoutElevation =  locationIdWithElevation.components(separatedBy: "@")[0];
            elevation = Int(locationIdWithElevation.components(separatedBy: "@")[1]) ?? 0;
        }
        
        let excludedElevation: Elevation = Elevation(elevation: elevation, elevationType: elevationType);
        return LocationIdWithElevation(locationId: locationIdWithoutElevation, elevation: excludedElevation);
    }
    
    func bounds(locationId: String) -> BoundsWithElevation {
        let locationIdWithElevation: LocationIdWithElevation = excludeElevation(locationIdWithElevation: locationId);
        let locationIdWithoutElevation: String = locationIdWithElevation.locationId;
        
        var evenBit: Bool = true;
        var latMin: Double = -90;
        var latMax: Double = 90;
        var lonMin: Double = -180;
        var lonMax: Double = 180;
        
        for i in 0..<locationIdWithoutElevation.count {
            let chr: Character = locationIdWithoutElevation[locationIdWithoutElevation.index(locationIdWithoutElevation.startIndex, offsetBy: i)];
            let firstIndex = UnlCore.base32.firstIndex(of: chr);
            if(firstIndex == nil) {
                // throw error
            };
            
            let idx: Int = UnlCore.base32.distance(from: UnlCore.base32.startIndex, to: firstIndex!);
            
            for n in (0..<5).reversed() {
                
                let bitN: Int = (idx >> n) & 1;
                
                if (evenBit) {
                    // longitude
                    let lonMid: Double = (lonMin + lonMax) / 2;
                    
                    if (bitN == 1) {
                        lonMin = lonMid;
                    } else {
                        lonMax = lonMid;
                    }
                } else {
                    // latitude
                    let latMid: Double = (latMin + latMax) / 2;
                    
                    if (bitN == 1) {
                        latMin = latMid;
                    } else {
                        latMax = latMid;
                    }
                }
                
                evenBit = !evenBit;
            }
        }
        
        let sw: Point = Point(lat: latMin, lon: lonMin);
        let ne: Point = Point(lat: latMax, lon: lonMax);
        let bounds: Bounds = Bounds(sw: sw, ne: ne);
        let elevation = Elevation(elevation: locationIdWithElevation.elevation.elevation, elevationType: locationIdWithElevation.elevation.elevationType);
        
        return BoundsWithElevation(bounds: bounds, elevation: elevation);
    }
    
    func adjacent(locationId: String, direction: String) -> String {
        let directionsString: String = "nsew";
        // based on github.com/davetroy/geohash-js
        
        let locationIdWithElevation: LocationIdWithElevation = excludeElevation(locationIdWithElevation: locationId);
        let locationIdString: String = locationIdWithElevation.locationId;
        let elevation: Int = locationIdWithElevation.elevation.elevation;
        let elevationType: String = locationIdWithElevation.elevation.elevationType;
        
        let directionChar: String = direction.lowercased();
        var directionNumber: Int;
        
        switch directionChar {
        case "s":
            directionNumber = 1;
            break;
        case "e":
            directionNumber = 2;
            break;
        case "w":
            directionNumber = 3;
            break;
        default:
            directionNumber = 0;
        }
        
        let neighbour: [[String]] = [
            ["p0r21436x8zb9dcf5h7kjnmqesgutwvy", "bc01fg45238967deuvhjyznpkmstqrwx"], //n
            ["14365h7k9dcfesgujnmqp0r2twvyx8zb", "238967debc01fg45kmstqrwxuvhjyznp"], //s
            ["bc01fg45238967deuvhjyznpkmstqrwx", "p0r21436x8zb9dcf5h7kjnmqesgutwvy"], //e
            ["238967debc01fg45kmstqrwxuvhjyznp", "14365h7k9dcfesgujnmqp0r2twvyx8zb"] //w
        ]
        
        let border: [[String]] = [
            ["prxz", "bcfguvyz"], //n
            ["028b", "0145hjnp"], //s
            ["bcfguvyz", "prxz"], //e
            ["0145hjnp", "028b"] //w
        ];
        
        let lastCh: Character = locationIdString.last!;
        var parent: String = String(locationIdString.dropLast());
        let type: Int = locationIdString.count % 2;
        
        // check for edge-cases which don't share common prefix
        if (border[directionNumber][type].firstIndex(of: lastCh) != nil && !parent.isEmpty) {
            parent = adjacent(locationId: parent, direction: direction);
        }
        
        // append letter for direction to parent
        let firstIndex = neighbour[directionNumber][type].firstIndex(of: lastCh);
        let idx: Int = neighbour[directionNumber][type].distance(from: neighbour[directionNumber][type].startIndex, to: firstIndex!);
        
        
        let nextLocationId: String = parent + String(UnlCore.base32[UnlCore.base32.index(UnlCore.base32.startIndex, offsetBy: idx)]);
        if(elevation != 0 && !elevationType.isEmpty){
            return appendElevation(locationIdWithoutElevation: nextLocationId, elevation: locationIdWithElevation.elevation);
        }
        
        return nextLocationId;
    }
    
    func neighbour(locationId: String) -> Neighbour {
        return Neighbour(
            n: adjacent(locationId: locationId, direction: "n"),
            ne: adjacent(locationId: adjacent(locationId: locationId, direction: "n"), direction: "e"),
            e: adjacent(locationId: locationId, direction: "e"),
            se: adjacent(locationId: adjacent(locationId: locationId, direction: "s"), direction: "e"),
            s: adjacent(locationId: locationId, direction: "s"),
            sw: adjacent(locationId: adjacent(locationId: locationId, direction: "s"), direction: "w"),
            w: adjacent(locationId: locationId, direction: "w"),
            nw: adjacent(locationId: adjacent(locationId: locationId, direction: "n"), direction: "w"))
    }
    
    func gridLines(bounds: Bounds, precision: Int) -> [[[Double]]] {
        var lines: [[[Double]]] = [];
        
        
        let lonMin: Double = bounds.sw.lon;
        let lonMax: Double = bounds.ne.lon;
        
        let latMin: Double = bounds.sw.lat;
        let latMax: Double = bounds.ne.lat;
        
        let swCellLocationId: String = encode(
            lat: bounds.sw.lat,
            lon: bounds.sw.lon,
            precision: precision,
            elevation: UnlCore.defaultElevation
        );
        
        let swCellBounds: BoundsWithElevation = self.bounds(locationId: swCellLocationId);
        
        let latStart: Double = swCellBounds.bounds.ne.lat;
        let lonStart: Double = swCellBounds.bounds.ne.lon;
        
        var currentCellLocationId: String = swCellLocationId;
        var currentCellBounds: BoundsWithElevation = swCellBounds;
        var currentCellNorthLatitude: Double = latStart;
        
        while (currentCellNorthLatitude <= latMax) {
            lines.append([[lonMin, currentCellNorthLatitude], [lonMax, currentCellNorthLatitude]]);
            
            currentCellLocationId = adjacent(locationId: currentCellLocationId, direction: "n");
            currentCellBounds = self.bounds(locationId: currentCellLocationId);
            currentCellNorthLatitude = currentCellBounds.bounds.ne.lat;
        }
        
        currentCellLocationId = swCellLocationId;
        var currentCellEastLongitude: Double = lonStart;
        
        while (currentCellEastLongitude <= lonMax) {
            lines.append([[currentCellEastLongitude, latMin],[currentCellEastLongitude, latMax]]);
            
            currentCellLocationId = adjacent(locationId: currentCellLocationId, direction: "e");
            currentCellBounds = self.bounds(locationId: currentCellLocationId);
            currentCellEastLongitude = currentCellBounds.bounds.ne.lon;
        }
        
        return lines;
    }
    
    func gridLines(bounds: Bounds) -> [[[Double]]] {
        return gridLines(bounds: bounds, precision: UnlCore.defaultPrecision);
    }
}
