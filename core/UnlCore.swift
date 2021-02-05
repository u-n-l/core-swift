//
//  UnlCore.swift
//  core
//
//  Created by Bogdan Simon on 22/01/2021.
//  Copyright © 2021 unl. All rights reserved.
//

/**
 Class that provides the unl-core functionalities.
 */

final class UnlCore {
    private static let base32 = "0123456789bcdefghjkmnpqrstuvwxyz";
    public static let defaultElevation = Elevation(elevation: 0, elevationType: "floor");
    public static let defaultPrecision = 9;
    private static let baseUrl: String = "https://map.unl.global/api/v1/location/";
    private static let wordsEndpoint: String = "words/";
    private static let geohashEndpoint: String = "geohash/";
    private static let coordinatesEndpoint: String = "coordinates/";
    private static let locationIdRegex: String = "^[0123456789bcdefghjkmnpqrstuvwxyz]{3,16}[@#]?[0-9]{0,3}$";
    private static let coordinatesRegex: String = "^-?[0-9]{0,2}\\.?[0-9]{0,16},\\s?-?[0-9]{0,3}\\.?[0-9]{0,16}$";
    
    private init() {}
    
    /**
     Encodes latitude/longitude coordinates to locationId, to specified precision.
     Elevation information is specified in elevation parameter.
     - Parameters:
     - lat: the latitude in degrees.
     - lon: the longitude in degrees.
     - precision: the number of characters in resulting locationId.
     - elevation: the elevation object, containing the elevation number and type: 'floor' | 'heightincm'.
     - Returns: the locationId of supplied latitude/longitude.
     - Throws: an error if the coordinates are invalid.
     */
    static func encode(lat: Double, lon: Double, precision: Int, elevation: Elevation) throws -> String {
        if(lat.isNaN || lon.isNaN){
            throw UnlCoreError.illegalArgument(messsage: "Invalid coordinates or precision");
        }
        
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
        
        return try UnlCore.appendElevation(locationIdWithoutElevation: locationId, elevation: elevationObject);
    }
    
    /**
     Encodes latitude/longitude coordinates to locationId, to specified precision.
     - Parameters:
     - lat: the latitude in degrees.
     - lon: the longitude in degrees.
     - precision: the number of characters in resulting locationId.
     - Returns: the locationId of supplied latitude/longitude.
     - Throws: an error if the coordinates are invalid.
     */
    static func encode(lat: Double, lon: Double, precision: Int) throws -> String {
        return try UnlCore.encode(lat: lat, lon: lon, precision: precision, elevation: UnlCore.defaultElevation );
    }
    
    /**
     Encodes latitude/longitude coordinates to locationId, to default precision: 9.
     - Parameters:
     - lat: the latitude in degrees.
     - lon: the longitude in degrees.
     - elevation: the elevation object, containing the elevation number and type: 'floor' | 'heightincm'.
     - Returns: the locationId of supplied latitude/longitude.
     - Throws: an error if the coordinates are invalid.
     */
    static func encode(lat: Double, lon: Double, elevation: Elevation) throws -> String {
        for p in 1..<(UnlCore.defaultPrecision + 1) {
            let hash: String = try UnlCore.encode(lat: lat, lon: lon, precision: p);
            let posn: PointWithElevation = try decode(locationId: hash);
            
            if(posn.coordinates.lat == lat && posn.coordinates.lon == lon){
                return hash;
            }
        }
        
        return try UnlCore.encode(lat: lat, lon: lon, precision: UnlCore.defaultPrecision, elevation: elevation);
    }
    
    /**
     Encodes latitude/longitude coordinates to locationId, to default precision: 9.
     - Parameters:
     - lat: the latitude in degrees.
     - lon: the longitude in degrees.
     - Returns: the locationId of supplied latitude/longitude.
     - Throws: an error if the coordinates are invalid.
     */
    static func encode(lat: Double, lon: Double) throws -> String {
        return try UnlCore.encode(lat: lat, lon: lon, elevation: UnlCore.defaultElevation);
    }
    
    /**
     Decodes locationId to latitude/longitude and elevation (location is approximate centre of locationId cell,
     to reasonable precision.
     - Parameters:
     - locationId: the locationId string to be converted to latitude/longitude.
     - Returns: an instance of PointWithElevation, containing: center of locationId, elevation info and n, e, s, w latitude/longitude bounds of the locationId.
     - Throws: an error if the locationId is invalid.
     */
    static func decode(locationId: String) throws -> PointWithElevation {
        let locationIdWithElevation: LocationIdWithElevation = try UnlCore.excludeElevation(locationIdWithElevation: locationId);
        let bounds: Bounds = try UnlCore.bounds(locationId: locationIdWithElevation.locationId);
        
        let latMin: Double = bounds.s;
        let lonMin: Double = bounds.w;
        
        let latMax: Double = bounds.n;
        let lonMax:Double = bounds.e;
        
        //cell center
        var lat: Double = (latMin + latMax) / 2.0;
        var lon: Double = (lonMin + lonMax) / 2.0;
        
        let latPrecision: Int = Int(floor(2 - log10(latMax - latMin) / log10(10)));
        let lonPrecision: Int = Int(floor(2 - log10(lonMax - lonMin) / log10(10)));
        
        lat = (lat * pow(10.0, Double(latPrecision))).rounded()/pow(10.0, Double(latPrecision));
        lon = (lon * pow(10.0, Double(lonPrecision))).rounded()/pow(10.0, Double(lonPrecision));
        
        let point: Point = Point(lat: lat, lon: lon);
        return PointWithElevation(coordinates: point, elevation: locationIdWithElevation.elevation, bounds: bounds);
        
    }
    
    /**
     Adds elevation chars and elevation.
     It is mainly used by internal functions.
     - Parameters:
     - locationIdWithoutElevation: the locationId without elevation chars.
     - elevation: the instance of Elevation, containing the height of the elevation and elevation type (floor | heightincm) as attributes.
     - Returns: a string containing locationId and elevation info.
     - Throws: an error if the locationId is invalid.
     */
    static func appendElevation(locationIdWithoutElevation: String, elevation: Elevation) throws -> String {
        if (locationIdWithoutElevation.count < 0) {
            throw UnlCoreError.illegalArgument(messsage: "Invalid locationId");
        }
        
        if (elevation.elevation == 0) {
            return locationIdWithoutElevation;
        }
        
        var elevationChar: Character = "@";
        if (elevation.elevationType == "heightincm") {
            elevationChar = "#";
        }
        
        return locationIdWithoutElevation + String(elevationChar) + String(elevation.elevation);
    }
    
    /**
     Returns locationId and elevation properties.
     It is mainly used by internal functions.
     - Parameters:
     - locationIdWithoutElevation: the locationId without elevation chars.
     - Returns: an instance of LocationIdWithElevation.
     - Throws: an error if the locationId is invalid.
     */
    static func excludeElevation(locationIdWithElevation: String) throws -> LocationIdWithElevation {
        if (locationIdWithElevation.count == 0) {
            throw UnlCoreError.illegalArgument(messsage: "Invalid locationId");
        }
        
        if (locationIdWithElevation.contains("#") && locationIdWithElevation.contains("@")) {
            throw UnlCoreError.illegalArgument(messsage: "Invalid locationId");
        }
        
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
    
    
    /**
     Returns n, e, s, w latitude/longitude bounds of specified locationId cell.
     - Parameters:
     - locationId: the cell that bounds are required of.
     - Returns:  an instance of Bounds, containing the n, e, s, w bounds of specified locationId cell together with the elevation information.
     - Throws: an error if the locationId is invalid.
     */
    static func bounds(locationId: String) throws -> Bounds {
        let locationIdWithElevation: LocationIdWithElevation = try excludeElevation(locationIdWithElevation: locationId);
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
            
            if(idx == -1){
                throw UnlCoreError.illegalArgument(messsage: "Invalid locationId");
            }
            
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
        
        return  Bounds(n: latMax, e: lonMax, s: latMin, w: lonMin);
    }
    
    /**
     Determines adjacent cell in given direction.
     - Parameters:
     - locationId:the cell to which adjacent cell is required.
     - direction: the direction from locationId (N/S/E/W).
     - Returns: the locationId of adjacent cell.
     - Throws: an error if the locationId is invalid.
     */
    static func adjacent(locationId: String, direction: String) throws -> String {
        let directionsString: String = "nsew";
        // based on github.com/davetroy/geohash-js
        
        let locationIdWithElevation: LocationIdWithElevation = try excludeElevation(locationIdWithElevation: locationId);
        let locationIdString: String = locationIdWithElevation.locationId;
        let elevation: Int = locationIdWithElevation.elevation.elevation;
        let elevationType: String = locationIdWithElevation.elevation.elevationType;
        
        let directionChar: String = direction.lowercased();
        var directionNumber: Int;
        
        if (locationIdString.count == 0) {
            throw UnlCoreError.illegalArgument(messsage: "Invalid locationId");
        }
        
        if (!directionsString.contains(direction)) {
            throw UnlCoreError.illegalArgument(messsage: "Invalid direction");
        }
        
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
            parent = try adjacent(locationId: parent, direction: direction);
        }
        
        // append letter for direction to parent
        let firstIndex = neighbour[directionNumber][type].firstIndex(of: lastCh);
        let idx: Int = neighbour[directionNumber][type].distance(from: neighbour[directionNumber][type].startIndex, to: firstIndex!);
        
        
        let nextLocationId: String = parent + String(UnlCore.base32[UnlCore.base32.index(UnlCore.base32.startIndex, offsetBy: idx)]);
        if(elevation != 0 && !elevationType.isEmpty){
            return try appendElevation(locationIdWithoutElevation: nextLocationId, elevation: locationIdWithElevation.elevation);
        }
        
        return nextLocationId;
    }
    
    /**
     Returns all 8 adjacent cells to specified locationId.
     - Parameters:
     - locationId:the locationId neighbours are required of.
     - Returns: an instance of Neighbour class containing the 8 adjacent cells of the specified locationId: n, ne, e, se, s, sw, w, nw.
     - Throws: an error if the locationId is invalid.
     */
    static func neighbour(locationId: String) throws -> Neighbour {
        return Neighbour(
            n: try UnlCore.adjacent(locationId: locationId, direction: "n"),
            ne: try UnlCore.adjacent(locationId: adjacent(locationId: locationId, direction: "n"), direction: "e"),
            e: try UnlCore.adjacent(locationId: locationId, direction: "e"),
            se: try UnlCore.adjacent(locationId: adjacent(locationId: locationId, direction: "s"), direction: "e"),
            s: try UnlCore.adjacent(locationId: locationId, direction: "s"),
            sw: try UnlCore.adjacent(locationId: adjacent(locationId: locationId, direction: "s"), direction: "w"),
            w: try UnlCore.adjacent(locationId: locationId, direction: "w"),
            nw: try UnlCore.adjacent(locationId: adjacent(locationId: locationId, direction: "n"), direction: "w"))
    }
    
    /**
     Returns the vertical and horizontal lines that can be used to draw a UNL grid in the specified
     n, e, s, w bounds and precision. Each line is represented by an array of two
     coordinates in the format: [[startLon, startLat], [endLon, endLat]].
     - Parameters:
     - bounds: the bound within to return the grid lines.
     - precision: the number of characters to consider for the locationId of a grid cell.
     - Returns: the grid lines.
     */
    static func gridLines(bounds: Bounds, precision: Int) throws -> [[[Double]]] {
        var lines: [[[Double]]] = [];
        
        let lonMin: Double = bounds.w;
        let lonMax: Double = bounds.e;
        
        let latMin: Double = bounds.s;
        let latMax: Double = bounds.n;
        
        let swCellLocationId: String = try UnlCore.encode(
            lat: bounds.s,
            lon: bounds.w,
            precision: precision,
            elevation: UnlCore.defaultElevation
        );
        
        let swCellBounds: Bounds = try UnlCore.bounds(locationId: swCellLocationId);
        
        let latStart: Double = swCellBounds.n;
        let lonStart: Double = swCellBounds.e;
        
        var currentCellLocationId: String = swCellLocationId;
        var currentCellBounds: Bounds = swCellBounds;
        var currentCellNorthLatitude: Double = latStart;
        
        while (currentCellNorthLatitude <= latMax) {
            lines.append([[lonMin, currentCellNorthLatitude], [lonMax, currentCellNorthLatitude]]);
            
            currentCellLocationId = try UnlCore.adjacent(locationId: currentCellLocationId, direction: "n");
            currentCellBounds = try UnlCore.bounds(locationId: currentCellLocationId);
            currentCellNorthLatitude = currentCellBounds.n;
        }
        
        currentCellLocationId = swCellLocationId;
        var currentCellEastLongitude: Double = lonStart;
        
        while (currentCellEastLongitude <= lonMax) {
            lines.append([[currentCellEastLongitude, latMin],[currentCellEastLongitude, latMax]]);
            
            currentCellLocationId = try adjacent(locationId: currentCellLocationId, direction: "e");
            currentCellBounds = try self.bounds(locationId: currentCellLocationId);
            currentCellEastLongitude = currentCellBounds.e;
        }
        
        return lines;
    }
    
    /**
     Returns the vertical and horizontal lines that can be used to draw a UNL grid in the specified
     n, e, s, w latitude/longitude bounds, using the default precision: 9. Each line is represented by an array of two
     coordinates in the format: [[startLon, startLat], [endLon, endLat]].
     - Parameters:
     - bounds: the bound within to return the grid lines
     - Returns: the grid lines.
     */
    static func gridLines(bounds: Bounds) throws -> [[[Double]]] {
        return try UnlCore.gridLines(bounds: bounds, precision: UnlCore.defaultPrecision);
    }
    
    /**
     Returns the location object, which encapsulates the coordinates, elevation, bounds, geohash and words,
     corresponding to the location string (id or lat-lon coordinates). It requires the api key used to access
     the location APIs.
     - Parameters:
     - location: the location (Id or lat-lon coordinates) of the point for which you would like the address.
     - apiKey: the UNL API key used to access the location APIs.
     - Returns: an instance of Location class, containing the coordinates, elevation, bounds, geohash and words.
     - Throws: an error if the api key string is empty, location is invalid or the call to location endpoint is unsuccessful.
     */
    static func toWords(location: String, apiKey: String, onSuccess: @escaping (Location) -> (), onFailure: @escaping(Error) -> ()) {
        if(apiKey.count == 0){
            onFailure(UnlCoreError.illegalArgument(messsage: "API key not set"));
            return;
        }
        
        var endpoint: String = "";
        
        let matchesLocationIdRegex = location.range(of: UnlCore.locationIdRegex, options: [.regularExpression, .anchored]) != nil;
        let matchesCoordinatesRegex = location.range(of: UnlCore.coordinatesRegex, options: [.regularExpression, .anchored]) != nil;
        
        if(matchesLocationIdRegex){
            endpoint = UnlCore.geohashEndpoint;
        } else if (matchesCoordinatesRegex) {
            endpoint = UnlCore.coordinatesEndpoint;
        } else {
            onFailure(UnlCoreError.illegalArgument(messsage: "Could not interpret your input, " + location + ". Expected a locationId or lat, lon coordinates."));
            return;
        }
        
        LocationService.callEndpoint(endPoint: UnlCore.baseUrl + endpoint + location, apiKey: apiKey, onSuccess:{response in
            let decoder = JSONDecoder()
            do {
                let location = try decoder.decode(Location.self, from: response);
                onSuccess(location);
            } catch let decodingError {
                onFailure(decodingError);
            }
        }, onFailure: {error in onFailure(error)})
    }
    
    /**
     Returns the location object, which encapsulates the coordinates, elevation, bounds, geohash and words,
     corresponding to the words string. It requires the api key used to access
     the location APIs.
     - Parameters:
     - words: the words representing the point for which you would like the coordinates.
     - apiKey: the UNL API key used to access the location APIs.
     - Returns: an instance of Location class, containing the coordinates, elevation, bounds, geohash and words.
     - Throws: an error if the api key string is empty or the call to location endpoint is unsuccessful.
     */
    static func words(words: String, apiKey: String, onSuccess: @escaping (Location) -> (), onFailure: @escaping(Error) -> ()) {
        if (apiKey.count == 0) {
            onFailure(UnlCoreError.illegalArgument(messsage: "API key not set"));
            return;
        }
        
        let endpoint: String = UnlCore.baseUrl + UnlCore.wordsEndpoint + words;
        
        LocationService.callEndpoint(endPoint: endpoint, apiKey: apiKey, onSuccess:{response in
            let decoder = JSONDecoder()
            
            do {
                let location = try decoder.decode(Location.self, from: response);
                onSuccess(location);
            } catch let decodingError {
                onFailure(decodingError);
            }
        }, onFailure: {error in onFailure(error)})
    }
}
