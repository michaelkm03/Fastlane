//
//  CreationFlowTypeHelperTests.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class CreationFlowTypeHelperTests: XCTestCase {

    func testCreationTypeForIdentifier() {
        
        XCTAssertEqual(CreationFlowTypeHelper.creationFlowTypeForIdentifier("Create Image"), VCreationFlowType.image)
        XCTAssertEqual(CreationFlowTypeHelper.creationFlowTypeForIdentifier("Create Video"), VCreationFlowType.video)
        XCTAssertEqual(CreationFlowTypeHelper.creationFlowTypeForIdentifier("Create Poll"), VCreationFlowType.poll)
        XCTAssertEqual(CreationFlowTypeHelper.creationFlowTypeForIdentifier("Create Text"), VCreationFlowType.text)
        XCTAssertEqual(CreationFlowTypeHelper.creationFlowTypeForIdentifier("Create GIF"), VCreationFlowType.GIF)
        XCTAssertEqual(CreationFlowTypeHelper.creationFlowTypeForIdentifier("Create from Library"), VCreationFlowType.library)
        XCTAssertEqual(CreationFlowTypeHelper.creationFlowTypeForIdentifier("Create from Native Camera"), VCreationFlowType.nativeCamera)
        XCTAssertEqual(CreationFlowTypeHelper.creationFlowTypeForIdentifier("Invalid Key"), VCreationFlowType.unknown)
    }
}
