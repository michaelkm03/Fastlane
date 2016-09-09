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
        
        XCTAssertEqual(CreationFlowTypeHelper.creationFlowTypeForIdentifier("Create Image"), VCreationFlowType.Image)
        XCTAssertEqual(CreationFlowTypeHelper.creationFlowTypeForIdentifier("Create Video"), VCreationFlowType.Video)
        XCTAssertEqual(CreationFlowTypeHelper.creationFlowTypeForIdentifier("Create Poll"), VCreationFlowType.Poll)
        XCTAssertEqual(CreationFlowTypeHelper.creationFlowTypeForIdentifier("Create Text"), VCreationFlowType.Text)
        XCTAssertEqual(CreationFlowTypeHelper.creationFlowTypeForIdentifier("Create GIF"), VCreationFlowType.GIF)
        XCTAssertEqual(CreationFlowTypeHelper.creationFlowTypeForIdentifier("Create Sticker"), VCreationFlowType.Sticker)
        XCTAssertEqual(CreationFlowTypeHelper.creationFlowTypeForIdentifier("Create from Library"), VCreationFlowType.Library)
        XCTAssertEqual(CreationFlowTypeHelper.creationFlowTypeForIdentifier("Create from Mixed Media Camera"), VCreationFlowType.MixedMediaCamera)
        XCTAssertEqual(CreationFlowTypeHelper.creationFlowTypeForIdentifier("Create from Native Camera"), VCreationFlowType.NativeCamera)
        XCTAssertEqual(CreationFlowTypeHelper.creationFlowTypeForIdentifier("Invalid Key"), VCreationFlowType.Unknown)
    }
}
