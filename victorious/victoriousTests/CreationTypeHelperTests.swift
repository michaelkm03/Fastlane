//
//  CreationTypeHelperTests.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class CreationTypeHelperTests: XCTestCase {

    func testCreationTypeForIdentifier() {
        
        XCTAssertEqual(CreationTypeHelper.creationTypeForIdentifier("Create Image"), VCreationType.Image)
        XCTAssertEqual(CreationTypeHelper.creationTypeForIdentifier("Create Video"), VCreationType.Video)
        XCTAssertEqual(CreationTypeHelper.creationTypeForIdentifier("Create Poll"), VCreationType.Poll)
        XCTAssertEqual(CreationTypeHelper.creationTypeForIdentifier("Create Text"), VCreationType.Text)
        XCTAssertEqual(CreationTypeHelper.creationTypeForIdentifier("Create GIF"), VCreationType.GIF)
        XCTAssertEqual(CreationTypeHelper.creationTypeForIdentifier("Invalid Key"), VCreationType.Unknown)
    }
}
