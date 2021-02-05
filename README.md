# UNL Core Swift

This library can be used to convert a UNL locationId to/from a latitude/longitude point. It also contains helper functions like retrieving the bounds of a UNL cell or the UNL grid lines for a given boundingbox (these can be used to draw a UNL cell or a UNL grid).

To integrate the core-swift library: 

1. Add this dependency in the podfile of your projet:

```
pod 'unl-core'
```

2. Run ```pod install```

You can read more on using CocoaPods [here](https://guides.cocoapods.org/using/using-cocoapods.html). 

To run the core-swift project:

1. Clone the repo
2. Open the terminal in the project directory
3. Run ```pod install```
4. Open unl-core.xcworkspace and run the project

## Classes

### Point 

```swift
public class Point: Equatable, Decodable {
    public let lat: Double;
    public let lon: Double;
    
    public init(lat: Double, lon: Double){
        self.lat = lat;
        self.lon = lon;
    }
}
```

### Bounds 

```swift
public class Bounds: Equatable, Decodable {
    public let n: Double;
    public let e: Double;
    public let s: Double;
    public let w: Double;
    
    public init(n: Double, e: Double, s: Double, w: Double){
        self.n = n;
        self.e = e;
        self.s = s;
        self.w = w;
    }
}
```

### Elevation

```swift
public class Elevation: Equatable {
    public let elevation: Int;
    public let elevationType: String;
    
    public init(elevation: Int, elevationType: String){
        self.elevation = elevation;
        self.elevationType = elevationType;
    }
}

```

### PointWithElevation

```swift
public class PointWithElevation: Equatable {
    public let coordinates: Point;
    public let elevation: Elevation;
    public let bounds: Bounds;
    public init(coordinates: Point, elevation: Elevation, bounds: Bounds){
        self.coordinates = coordinates;
        self.elevation = elevation;
        self.bounds = bounds;
    }
}
```

### LocationIdWithElevation 

```swift
public class LocationIdWithElevation: Equatable {
    public let locationId: String;
    public let elevation: Elevation;
    public init(locationId: String, elevation: Elevation){
        self.locationId = locationId;
        self.elevation = elevation;
    }
}
```

### Neighbours 

```swift
public class Neighbour: Equatable {
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
    }
}
```

### Location 

```swift
public class Location: Equatable, Decodable {
    public let point: Point;
    public let elevation: Elevation;
    public let bounds: Bounds;
    public let geohash: String;
    public let words: String;
    
    public init(point: Point, elevation: Elevation, bounds: Bounds, geohash: String, words: String){
        self.point = point;
        self.elevation = elevation;
        self.bounds = bounds;
        self.geohash = geohash;
        self.words = words;
    }
}
```

## UnlCore methods

You can import the UnlCore class into your file, to call any of the methods described below:

```swift
import unl-core;
```
### encode

Encodes latitude/longitude coordinates to locationId. There are multiple signatures for the encode method.

The encoding is done to the given precision. The last parameter is used to specify the elevation information: number and type (floor | "heightincm").
```swift
public static func encode(lat: Double, lon: Double, precision: Int, elevation: Elevation) throws -> String
```


Example:
```swift
UnlCore.encode(lat: 57.648, lon: 10.41, 6, elevation: Elevation(elevation: 87, elevationType: "heightincm"));
```
Returns:
```swift
"u4pruy#87"
```

The precision and/or elevation can be skipped from the parameters. In this case, the default values will be used:

```swift
public static let defaultPrecision = 9;
public static let defaultElevation = Elevation(elevation: 0, elevationType: "floor");
```


```swift
public static func encode(lat: Double, lon: Double, precision: Int) throws -> String
```

Example:
```swift
UnlCore.encode(lat: 57.648, lon: 10.41, precision: 6);
```
Returns:
```swift
"u4pruy"
```

```swift
public static func encode(lat: Double, lon: Double, elevation: Elevation) throws -> String
```

Example:
```swift
UnlCore.encode(lat: 52.37686, lon: 4.90065, elevation: Elevation(-2));
```
Returns:
```swift
"u173zwbt3@-2"
```

```swift
public static func encode(lat: Double, lon: Double) throws -> String
```
Example:
```swift
UnlCore.encode(lat: 52.37686, lon: 4.90065);
```

Returns:
```swift
"u173zwbt3"
```

### Decode

```swift
public static func decode(locationId: String) throws -> PointWithElevation
```
Decodes a locationId to latitude/longitude (location is approximate centre of locationId cell, to reasonable precision).

Example: 

```swift
UnlCore.decode(locationId: "u173zwbt3");
```

Returns a PointWithElevation object. Below is the json representation of the returned object:

```swift
{
   "coordinates":{
      "lat":52.376869,
      "lon":4.900653
   },
   "elevation":{
      "elevation":0,
      "elevationType":"floor"
   },
   "bounds":{
      "n":52.37689018249512,
      "e":4.900674819946289,
      "s":52.37684726715088,
      "w":4.900631904602051
   }
}
```

### Bounds
Returns n, e, s, w latitude/longitude bounds of specified locationId cell, along with the elevation information.

```swift
public static func bounds(locationId: String) throws -> Bounds
```

Example:
```swift
UnlCore.bounds(locationId: "u173zwbt3");
```

Returns a Bounds object. Below is the json representation of the returned object:

```swift
{
   "n":52.37689018249512,
   "e":4.900674819946289,
   "s":52.37684726715088,
   "w":4.900631904602051
}
``` 

## gridLines
Returns the vertical and horizontal lines that can be used to draw a UNL grid in the specified
n, e, s, w latitude/longitude bounds and precision. Each line is represented by an array of two
coordinates in the format: [[startLon, startLat], [endLon, endLat]].

```swift
public static func gridLines(bounds: Bounds, precision: Int) throws -> [[[Double]]]
```

If the precision parameter is not passed, the default precision will be used: 9.

Example:

```swift
let bounds: Bounds = Bounds(n: 46.77227194246396, e: 23.59560827603795, s: 46.77210936378606, w: 23.595436614661565);
UnlCore.gridLines(bounds: bounds, precision: 12);

```

Will return an ArrayList of length 1481, containing the array of lines:
```
[[startLon, startLat], [endLon, endLat]]
...
```

## adjacent 
Determines adjacent cell in given direction: "N" | "S" | "E" | "W".

```swift
public static func adjacent(locationId: String, direction: String) throws -> String
```

Example:

```swift
UnlCore.adjacent(locationId: "ezzz@5", direction: "N");
```

Returns a string:

```swift
"gbpb@5"
````

### neighbours

Returns all 8 adjacent cells to specified locationId.

```swift
public static func neighbour(locationId: String) throws -> Neighbour
```

Example:

```swift
UnlCore.neighbours(locationId: "ezzz");
```

Returns a Neighbour object, containing the 8 adjacent cells to specified locationId. Below is the JSON representation of the object:

```swift
{
   "n":"gbpb",
   "ne":"u000",
   "e":"spbp",
   "se":"spbn",
   "s":"ezzy",
   "sw":"ezzw",
   "w":"ezzx",
   "nw":"gbp8"
}
```

### excludeElevation

Returns an instance of LocationIdWithElevation, containing the locationId and elevation properties. It is mainly used by internal functions.

```swift
public static func excludeElevation(locationIdWithElevation: String) throws -> LocationIdWithElevation
```

Example:

```swift
UnlCore.excludeElevation(locationIdWithElevation: "6gkzwgjz@5");
```

Returns a LocationIdWithElevation object. The JSON representation:

```swift
{
   "locationId":"6gkzwgjz",
   "elevation":{
      "elevation":5,
      "elevationType":"floor"
   }
}
```

### appendElevation 

Adds elevation chars and elevation to a locationId. It is mainly used by internal functions.

```swift
public static func appendElevation(locationIdWithoutElevation: String, elevation: Elevation) throws -> String
```

Example:

```swift
let elevation: Elevation = Elevation(elevation: 5, elevationType: "floor"):
UnlCore.appendElevation(locationIdWithoutElevation: "6gkzwgjz", elevation: elevation);
```

Returns a string: 
```swift
"6gkzwgjz@5"
```

### toWords
It requires the api key used to access
the location APIs.  Returns the location object, which encapsulates the coordinates, elevation, bounds, geohash and words,
corresponding to the location string (id or lat-lon coordinates) in case of sucess. onFailure callback is called if the request to the locationAPI is not sucessful.

```swift
```swift
public static func toWords(location: String, apiKey: String, onSuccess: @escaping (Location) -> (), onFailure: @escaping(Error) -> ())
```
### words

It requires the api key used to access
the location APIs. Returns the location object, which encapsulates the coordinates, elevation, bounds, geohash and words,
corresponding to the words string, in case of success. onFailure callback is called if the request to the locationAPI is not sucessful.

```swift
public static func words(words: String, apiKey: String, onSuccess: @escaping (Location) -> (), onFailure: @escaping(Error) -> ())
```
In order to generate the apiKey and access the location APIs, you need to create a developer account on [map.unl.global](https://unl.global/developers/).
You can read more on authentication and api keys at: https://developer.unl.global/docs/authentication.

## Contributing
Pull requests are welcome.

Please make sure to update tests as appropriate.

## License
Licensed under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
