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
        let unlCore = UnlCore.getInstance();
        
        /* encodes Jutland */
        XCTAssert(try unlCore.encode(lat: 57.648, lon: 10.41, precision: 6) == "u4pruy", "encode Jutland result is incorrect");
        
        /* encodes Jutland floor 5 */
        XCTAssert(try unlCore.encode(lat: 57.648, lon: 10.41, precision: 6, elevation: Elevation(elevation: 5)) == "u4pruy@5", "encode Jutland floor 5 result is incorrect");
        
        /* encodes Jutland floor -2 */
        XCTAssert(try unlCore.encode(lat: 57.648, lon: 10.41, precision: 6, elevation: Elevation(elevation: -2)) == "u4pruy@-2", "encode Jutland floor -2 result is incorrect");
        
        /* encodes Jutland heightincm 87 */
        XCTAssert(try unlCore.encode(lat: 57.648, lon: 10.41, precision: 6, elevation: Elevation(elevation: 87, elevationType: "heightincm")) == "u4pruy#87", "encode Jutland heightincm 87 result is incorrect");
        
        /* encodes Jutland with default precision 9 */
        XCTAssert(try unlCore.encode(lat: 57.64, lon: 10.41) == "u4pruvh36", "encode Jutland with default precision 9 result is incorrect");
        
        /* encodes Curitiba */
        XCTAssert(try unlCore.encode(lat: -25.38262, lon: -49.26561, precision: 8) == "6gkzwgjz", "encode Curitiba result is incorrect");
        
        /* matches  locationId */
        XCTAssert(try unlCore.encode(lat: 37.25, lon: 123.75, precision: 12) == "wy85bj0hbp21", "encode result is incorrect - locationIds do not match");
    }
    
    func testDecode() {
        let unlCore = UnlCore.getInstance();
        
        /* decodes Jutland */
        XCTAssertEqual(try unlCore.decode(locationId: "u4pruy"),
                       PointWithElevation(coordinates: Point(lat: 57.648, lon: 10.41), elevation: UnlCore.defaultElevation,
                                          bounds: BoundsWithElevation(bounds: Bounds(sw: Point(lat: 57.645263671875, lon: 10.404052734375), ne: Point(lat: 57.6507568359375, lon: 10.4150390625)), elevation: UnlCore.defaultElevation)
            ), "decode Jutland result is incorrect"
        );
        
        /* decodes Justland floor 3 */
        XCTAssertEqual(try unlCore.decode(locationId: "u4pruy@3"),
                       PointWithElevation(coordinates: Point(lat: 57.648, lon: 10.41), elevation: Elevation(elevation: 3, elevationType: "floor"),
                                          bounds: BoundsWithElevation(bounds: Bounds(sw: Point(lat: 57.645263671875, lon: 10.404052734375), ne: Point(lat: 57.6507568359375, lon: 10.4150390625)), elevation: UnlCore.defaultElevation)
            ), "decode Jutland floor 3 result is incorrect"
        );
        
        /* decodes Justland floor 0 */
        XCTAssertEqual(try unlCore.decode(locationId: "u4pruy@0"),
                       PointWithElevation(coordinates: Point(lat: 57.648, lon: 10.41), elevation: UnlCore.defaultElevation,
                                          bounds: BoundsWithElevation(bounds: Bounds(sw: Point(lat: 57.645263671875, lon: 10.404052734375), ne: Point(lat: 57.6507568359375, lon: 10.4150390625)), elevation: UnlCore.defaultElevation)
            ), "decode Jutland floor 0 result is incorrect"
        );
        
        /* decodes Justland floor -2 */
        XCTAssertEqual(try unlCore.decode(locationId: "u4pruy@-2"),
                       PointWithElevation(coordinates: Point(lat: 57.648, lon: 10.41), elevation: Elevation(elevation: -2, elevationType: "floor"),
                                          bounds: BoundsWithElevation(bounds: Bounds(sw: Point(lat: 57.645263671875, lon: 10.404052734375), ne: Point(lat: 57.6507568359375, lon: 10.4150390625)), elevation: UnlCore.defaultElevation)
            ), "decode Jutland floor -2 result is incorrect"
        );
        
        /* decodes Jutland heightincm 87 */
        XCTAssertEqual(try unlCore.decode(locationId: "u4pruy#87"),
                       PointWithElevation(coordinates: Point(lat: 57.648, lon: 10.41), elevation: Elevation(elevation: 87, elevationType: "heightincm"),
                                          bounds: BoundsWithElevation(bounds: Bounds(sw: Point(lat: 57.645263671875, lon: 10.404052734375), ne: Point(lat: 57.6507568359375, lon: 10.4150390625)), elevation: UnlCore.defaultElevation)
            ), "decode Jutland heightincm 87 result is incorrect"
        );
        
        /* decodes Jutland heightincm 0 */
        XCTAssertEqual(try unlCore.decode(locationId: "u4pruy#0"),
                       PointWithElevation(coordinates: Point(lat: 57.648, lon: 10.41), elevation: Elevation(elevation: 0, elevationType: "heightincm"),
                                          bounds: BoundsWithElevation(bounds: Bounds(sw: Point(lat: 57.645263671875, lon: 10.404052734375), ne: Point(lat: 57.6507568359375, lon: 10.4150390625)), elevation: UnlCore.defaultElevation)
            ), "decode Jutland heightincm 0 result is incorrect"
        );
        
        /* decodes Curitiba */
        XCTAssertEqual(try unlCore.decode(locationId: "6gkzwgjz"),
                       PointWithElevation(coordinates: Point(lat: -25.38262, lon: -49.26561), elevation: UnlCore.defaultElevation,
                                          bounds: BoundsWithElevation(bounds: Bounds(sw: Point(lat: -25.382709503173828, lon: -49.265785217285156), ne: Point(lat: -25.382537841796875, lon: -49.26544189453125)), elevation: UnlCore.defaultElevation)
            ), "decode Curitiba result is incorrect"
        );
        
        /* decodes Curitiba floor 5 */
        XCTAssertEqual(try unlCore.decode(locationId: "6gkzwgjz@5"),
                       PointWithElevation(coordinates: Point(lat: -25.38262, lon: -49.26561), elevation: Elevation(elevation: 5,elevationType: "floor"),
                                          bounds: BoundsWithElevation(bounds: Bounds(sw: Point(lat: -25.382709503173828, lon: -49.265785217285156), ne: Point(lat: -25.382537841796875, lon: -49.26544189453125)), elevation: UnlCore.defaultElevation)
            ), "decode Curitiba floor 5 result is incorrect"
        );
        
        /* decodes Curitiba heightincm 90 */
        XCTAssertEqual(try unlCore.decode(locationId: "6gkzwgjz#90"),
                       PointWithElevation(coordinates: Point(lat: -25.38262, lon: -49.26561), elevation: Elevation(elevation: 90,elevationType: "heightincm"),
                                          bounds: BoundsWithElevation(bounds: Bounds(sw: Point(lat: -25.382709503173828, lon: -49.265785217285156), ne: Point(lat: -25.382537841796875, lon: -49.26544189453125)), elevation: UnlCore.defaultElevation)
            ), "decode Curitiba heightincm 90 result is incorrect"
        );
    }
    
    func testAppendElevation() {
        let unlCore = UnlCore.getInstance();
        
        /* appends elevation Curitiba 5th floor */
        XCTAssertEqual(
            try unlCore.appendElevation(locationIdWithoutElevation:"6gkzwgjz" , elevation: Elevation(elevation: 5)), "6gkzwgjz@5", "append elevation Curitiba 5th floor result is incorrect"
        );
        
        /* appends elevation Curitiba above 87cm */
        XCTAssertEqual(
            try unlCore.appendElevation(locationIdWithoutElevation:"6gkzwgjz" , elevation: Elevation(elevation: 87, elevationType: "heightincm")), "6gkzwgjz#87", "append elevation Curitiba 5th floor result is incorrect"
        );
    }
    
    func testExcludeElevation() {
        let unlCore = UnlCore.getInstance();
        
        /* excludes elevation Curitiba 5th floor */
        XCTAssertEqual(
            try unlCore.excludeElevation(locationIdWithElevation: "6gkzwgjz@5"),
            LocationIdWithElevation(locationId: "6gkzwgjz", elevation: Elevation(elevation: 5, elevationType: "floor")),
            "exclude elevation Curitiba 5th floor result is incorrect"
        );
        
        /* excludes elevation Curitiba above 87cm */
        XCTAssertEqual(
            try unlCore.excludeElevation(locationIdWithElevation: "6gkzwgjz#87"),
            LocationIdWithElevation(locationId: "6gkzwgjz", elevation: Elevation(elevation: 87, elevationType: "heightincm")),
            "exclude elevation Curitiba above 87cm result is incorrect"
        );
    }
    
    func testAdjacent() {
        let unlCore = UnlCore.getInstance();
        
        /* adjacent north */
        XCTAssert(
            try unlCore.adjacent(locationId: "ezzz@5", direction: "n") == "gbpb@5",
            "adjacent north result is incorrect"
        );
    }
    
    func testNeighbour() {
        let unlCore = UnlCore.getInstance();
        
        /*  fetches neighbours */
        XCTAssertEqual(
            try unlCore.neighbour(locationId: "ezzz"),
            Neighbour(n: "gbpb", ne: "u000", e: "spbp", se: "spbn", s: "ezzy", sw: "ezzw", w: "ezzx", nw: "gbp8"),
            "fetch neighbours result is incorrect"
        );
        
        /*  fetches neighbours 5th floor */
        XCTAssertEqual(
            try unlCore.neighbour(locationId: "ezzz@5"),
            Neighbour(n: "gbpb@5", ne: "u000@5", e: "spbp@5", se: "spbn@5", s: "ezzy@5", sw: "ezzw@5", w: "ezzx@5", nw: "gbp8@5"),
            "fetch neighbours 5th floor result is incorrect"
        );
        
        /* fetches neighbours -2 floor */
        XCTAssertEqual(
            try unlCore.neighbour(locationId: "ezzz@-2"),
            Neighbour(n: "gbpb@-2", ne: "u000@-2", e: "spbp@-2", se: "spbn@-2", s: "ezzy@-2", sw: "ezzw@-2", w: "ezzx@-2", nw: "gbp8@-2"),
            "fetch neighbours -2 floor result is incorrect"
        );
        
        /* fetches neighbours above 87cm */
        XCTAssertEqual(
            try unlCore.neighbour(locationId: "ezzz#87"),
            Neighbour(n: "gbpb#87", ne: "u000#87", e: "spbp#87", se: "spbn#87", s: "ezzy#87", sw: "ezzw#87", w: "ezzx#87", nw: "gbp8#87"),
            "fetch neighbours above 87cm result is incorrect"
        );
        
        /* fetches neighbours below 5cm */
        XCTAssertEqual(
            try unlCore.neighbour(locationId: "ezzz#-5"),
            Neighbour(n: "gbpb#-5", ne: "u000#-5", e: "spbp#-5", se: "spbn#-5", s: "ezzy#-5", sw: "ezzw#-5", w: "ezzx#-5", nw: "gbp8#-5"),
            "fetch neighbours below 5cm result is incorrect"
        );
    }
    
    func testGridLines() {
        let unlCore = UnlCore.getInstance();
        
        /* retrieves grid lines with precision 9 */
        XCTAssert(
            try unlCore.gridLines(bounds: Bounds(sw: Point(lat: 46.77210936378606, lon: 23.595436614661565), ne: Point(lat: 46.77227194246396, lon: 23.59560827603795)), precision: 9).count == 7,
            "gridLines with precision 9 result is incorrect"
        );
        
        /* retrieves grid lines with no precision specified (default 9) */
        XCTAssert(
            try unlCore.gridLines(bounds: Bounds(sw: Point(lat: 46.77210936378606, lon: 23.595436614661565), ne: Point(lat: 46.77227194246396, lon: 23.59560827603795))).count == 7,
            "gridLines with no precision specified result is incorrect"
        );
        
        /* retrieves grid lines with precision 12 */
        XCTAssert(
            try unlCore.gridLines(bounds: Bounds(sw: Point(lat: 46.77210936378606, lon: 23.595436614661565), ne: Point(lat: 46.77227194246396, lon: 23.59560827603795)), precision: 12).count == 1481,
            "gridLines with precision 12 result is incorrect"
        );
    }
