////
////  ExperimentSettingsTests.swift
////  victorious
////
////  Created by Josh Hinman on 8/14/15.
////  Copyright (c) 2015 Victorious. All rights reserved.
////
//
//import UIKit
//import XCTest
//@testable import victorious
//
//class ExperimentSettingsTests: XCTestCase {
//
//    func testSaveAndLoad() {
//        
//        let settings = ExperimentSettings()
//        let experimentIDs = Set(arrayLiteral: 0, 1, 2, 3)
//        settings.activeExperiments = experimentIDs
//        
//        let settings2 = ExperimentSettings()
//        XCTAssertEqual(settings2.activeExperiments!, experimentIDs)
//    }
//    
//    func testExplicitNoExperiments() {
//        
//        let settings = ExperimentSettings()
//        settings.activeExperiments = Set()
//        
//        let settings2 = ExperimentSettings()
//        XCTAssertEqual(settings2.activeExperiments!, Set())
//        XCTAssertEqual(settings2.commaSeparatedList()!, "")
//    }
//    
//    func testReset() {
//        
//        let settings = ExperimentSettings()
//        settings.reset()
//        XCTAssertNil(settings.activeExperiments)
//        XCTAssertNil(settings.commaSeparatedList())
//    }
//}
