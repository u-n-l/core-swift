//
//  coreTests.swift
//  coreTests
//
//  Created by Bogdan Simon on 21/01/2021.
//  Copyright © 2021 unl. All rights reserved.
//

import XCTest
@testable import core

class coreTests: XCTestCase {
    func testEncode() {
        /* encodes Jutland */
        XCTAssert(try UnlCore.encode(lat: 57.648, lon: 10.41, precision: 6) == "u4pruy", "encode Jutland result is incorrect");
        
        /* encodes Jutland floor 5 */
        XCTAssert(try UnlCore.encode(lat: 57.648, lon: 10.41, precision: 6, elevation: Elevation(elevation: 5)) == "u4pruy@5", "encode Jutland floor 5 result is incorrect");
        
        /* encodes Jutland floor -2 */
        XCTAssert(try UnlCore.encode(lat: 57.648, lon: 10.41, precision: 6, elevation: Elevation(elevation: -2)) == "u4pruy@-2", "encode Jutland floor -2 result is incorrect");
        
        /* encodes Jutland heightincm 87 */
        XCTAssert(try UnlCore.encode(lat: 57.648, lon: 10.41, precision: 6, elevation: Elevation(elevation: 87, elevationType: "heightincm")) == "u4pruy#87", "encode Jutland heightincm 87 result is incorrect");
        
        /* encodes Jutland with default precision 9 */
        XCTAssert(try UnlCore.encode(lat: 57.64, lon: 10.41) == "u4pruvh36", "encode Jutland with default precision 9 result is incorrect");
        
        /* encodes Curitiba */
        XCTAssert(try UnlCore.encode(lat: -25.38262, lon: -49.26561, precision: 8) == "6gkzwgjz", "encode Curitiba result is incorrect");
        
        /* matches  locationId */
        XCTAssert(try UnlCore.encode(lat: 37.25, lon: 123.75, precision: 12) == "wy85bj0hbp21", "encode result is incorrect - locationIds do not match");
    }
    
    func testDecode() {
        /* decodes Jutland */
        XCTAssertEqual(try UnlCore.decode(locationId: "u4pruy"),
                       PointWithElevation(coordinates: Point(lat: 57.648, lon: 10.41), elevation: UnlCore.defaultElevation,
                                          bounds: Bounds(
                                            n: 57.6507568359375,
                                            e: 10.4150390625,
                                            s: 57.645263671875,
                                            w: 10.404052734375)
            ), "decode Jutland result is incorrect"
        );
        
        /* decodes Justland floor 3 */
        XCTAssertEqual(try UnlCore.decode(locationId: "u4pruy@3"),
                       PointWithElevation(coordinates: Point(lat: 57.648, lon: 10.41), elevation: Elevation(elevation: 3, elevationType: "floor"),
                                          bounds: Bounds(
                                            n: 57.6507568359375,
                                            e: 10.4150390625,
                                            s: 57.645263671875,
                                            w:10.404052734375)
            ), "decode Jutland floor 3 result is incorrect"
        );
        
        /* decodes Justland floor 0 */
        XCTAssertEqual(try UnlCore.decode(locationId: "u4pruy@0"),
                       PointWithElevation(coordinates: Point(lat: 57.648, lon: 10.41), elevation: UnlCore.defaultElevation,
                                          bounds: Bounds(
                                            n: 57.6507568359375,
                                            e: 10.4150390625,
                                            s: 57.645263671875,
                                            w:10.404052734375)
            ), "decode Jutland floor 0 result is incorrect"
        );
        
        /* decodes Justland floor -2 */
        XCTAssertEqual(try UnlCore.decode(locationId: "u4pruy@-2"),
                       PointWithElevation(coordinates: Point(lat: 57.648, lon: 10.41), elevation: Elevation(elevation: -2, elevationType: "floor"),
                                          bounds: Bounds(
                                            n: 57.6507568359375,
                                            e: 10.4150390625,
                                            s: 57.645263671875,
                                            w:10.404052734375)
            ), "decode Jutland floor -2 result is incorrect"
        );
        
        /* decodes Jutland heightincm 87 */
        XCTAssertEqual(try UnlCore.decode(locationId: "u4pruy#87"),
                       PointWithElevation(coordinates: Point(lat: 57.648, lon: 10.41), elevation: Elevation(elevation: 87, elevationType: "heightincm"),
                                          bounds: Bounds(
                                            n: 57.6507568359375,
                                            e: 10.4150390625,
                                            s: 57.645263671875,
                                            w:10.404052734375
                        )
            ), "decode Jutland heightincm 87 result is incorrect"
        );
        
        /* decodes Jutland heightincm 0 */
        XCTAssertEqual(try UnlCore.decode(locationId: "u4pruy#0"),
                       PointWithElevation(coordinates: Point(lat: 57.648, lon: 10.41), elevation: Elevation(elevation: 0, elevationType: "heightincm"),
                                          bounds: Bounds(
                                            n: 57.6507568359375,
                                            e: 10.4150390625,
                                            s: 57.645263671875,
                                            w:10.404052734375
                        )
            ), "decode Jutland heightincm 0 result is incorrect"
        );
        
        /* decodes Curitiba */
        XCTAssertEqual(try UnlCore.decode(locationId: "6gkzwgjz"),
                       PointWithElevation(coordinates: Point(lat: -25.38262, lon: -49.26561), elevation: UnlCore.defaultElevation,
                                          bounds: Bounds(
                                            n: -25.382537841796875,
                                            e: -49.26544189453125,
                                            s: -25.382709503173828,
                                            w:-49.265785217285156)
            ), "decode Curitiba result is incorrect"
        );
        
        /* decodes Curitiba floor 5 */
        XCTAssertEqual(try UnlCore.decode(locationId: "6gkzwgjz@5"),
                       PointWithElevation(coordinates: Point(lat: -25.38262, lon: -49.26561), elevation: Elevation(elevation: 5,elevationType: "floor"),
                                          bounds: Bounds(
                                            n: -25.382537841796875,
                                            e: -49.26544189453125,
                                            s: -25.382709503173828,
                                            w:-49.265785217285156
                        )
            ), "decode Curitiba floor 5 result is incorrect"
        );
        
        /* decodes Curitiba heightincm 90 */
        XCTAssertEqual(try UnlCore.decode(locationId: "6gkzwgjz#90"),
                       PointWithElevation(coordinates: Point(lat: -25.38262, lon: -49.26561), elevation: Elevation(elevation: 90,elevationType: "heightincm"),
                                          bounds: Bounds(
                                            n: -25.382537841796875,
                                            e: -49.26544189453125,
                                            s: -25.382709503173828,
                                            w:-49.265785217285156
                        )
            ), "decode Curitiba heightincm 90 result is incorrect"
        );
    }
    
    func testAppendElevation() {
        /* appends elevation Curitiba 5th floor */
        XCTAssertEqual(
            try UnlCore.appendElevation(locationIdWithoutElevation:"6gkzwgjz" , elevation: Elevation(elevation: 5)), "6gkzwgjz@5", "append elevation Curitiba 5th floor result is incorrect"
        );
        
        /* appends elevation Curitiba above 87cm */
        XCTAssertEqual(
            try UnlCore.appendElevation(locationIdWithoutElevation:"6gkzwgjz" , elevation: Elevation(elevation: 87, elevationType: "heightincm")), "6gkzwgjz#87", "append elevation Curitiba 5th floor result is incorrect"
        );
    }
    
    func testExcludeElevation() {
        /* excludes elevation Curitiba 5th floor */
        XCTAssertEqual(
            try UnlCore.excludeElevation(locationIdWithElevation: "6gkzwgjz@5"),
            LocationIdWithElevation(locationId: "6gkzwgjz", elevation: Elevation(elevation: 5, elevationType: "floor")),
            "exclude elevation Curitiba 5th floor result is incorrect"
        );
        
        /* excludes elevation Curitiba above 87cm */
        XCTAssertEqual(
            try UnlCore.excludeElevation(locationIdWithElevation: "6gkzwgjz#87"),
            LocationIdWithElevation(locationId: "6gkzwgjz", elevation: Elevation(elevation: 87, elevationType: "heightincm")),
            "exclude elevation Curitiba above 87cm result is incorrect"
        );
    }
    
    func testAdjacent() {
        /* adjacent north */
        XCTAssert(
            try UnlCore.adjacent(locationId: "ezzz@5", direction: "n") == "gbpb@5",
            "adjacent north result is incorrect"
        );
    }
    
    func testNeighbours() {
        /*  fetches neighbours */
        XCTAssertEqual(
            try UnlCore.neighbours(locationId: "ezzz"),
            Neighbours(n: "gbpb", ne: "u000", e: "spbp", se: "spbn", s: "ezzy", sw: "ezzw", w: "ezzx", nw: "gbp8"),
            "fetch neighbours result is incorrect"
        );
        
        /*  fetches neighbours 5th floor */
        XCTAssertEqual(
            try UnlCore.neighbours(locationId: "ezzz@5"),
            Neighbours(n: "gbpb@5", ne: "u000@5", e: "spbp@5", se: "spbn@5", s: "ezzy@5", sw: "ezzw@5", w: "ezzx@5", nw: "gbp8@5"),
            "fetch neighbours 5th floor result is incorrect"
        );
        
        /* fetches neighbours -2 floor */
        XCTAssertEqual(
            try UnlCore.neighbours(locationId: "ezzz@-2"),
            Neighbours(n: "gbpb@-2", ne: "u000@-2", e: "spbp@-2", se: "spbn@-2", s: "ezzy@-2", sw: "ezzw@-2", w: "ezzx@-2", nw: "gbp8@-2"),
            "fetch neighbours -2 floor result is incorrect"
        );
        
        /* fetches neighbours above 87cm */
        XCTAssertEqual(
            try UnlCore.neighbours(locationId: "ezzz#87"),
            Neighbours(n: "gbpb#87", ne: "u000#87", e: "spbp#87", se: "spbn#87", s: "ezzy#87", sw: "ezzw#87", w: "ezzx#87", nw: "gbp8#87"),
            "fetch neighbours above 87cm result is incorrect"
        );
        
        /* fetches neighbours below 5cm */
        XCTAssertEqual(
            try UnlCore.neighbours(locationId: "ezzz#-5"),
            Neighbours(n: "gbpb#-5", ne: "u000#-5", e: "spbp#-5", se: "spbn#-5", s: "ezzy#-5", sw: "ezzw#-5", w: "ezzx#-5", nw: "gbp8#-5"),
            "fetch neighbours below 5cm result is incorrect"
        );
    }
    
    func testGridLines() {
        /* retrieves grid lines with precision 9 */
        XCTAssert(
            try UnlCore.gridLines(bounds: Bounds(
                n:  46.77227194246396,
                e: 23.59560827603795,
                s: 46.77210936378606,
                w:23.595436614661565), precision: 9).count == 7,
            "gridLines with precision 9 result is incorrect"
        );
        
        /* retrieves grid lines with no precision specified (default 9) */
        XCTAssert(
            try UnlCore.gridLines(bounds: Bounds(
                n:  46.77227194246396,
                e: 23.59560827603795,
                s: 46.77210936378606,
                w:23.595436614661565
            )).count == 7,
            "gridLines with no precision specified result is incorrect"
        );
        
        /* retrieves grid lines with precision 12 */
        XCTAssert(
            try UnlCore.gridLines(bounds: Bounds(
                n:  46.77227194246396,
                e: 23.59560827603795,
                s: 46.77210936378606,
                w:23.595436614661565
            ), precision: 12).count == 1481,
            "gridLines with precision 12 result is incorrect"
        );
    }
}
