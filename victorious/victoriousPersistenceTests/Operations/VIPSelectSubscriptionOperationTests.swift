//
//  VIPSelectSubscriptionOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 9/28/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class VIPSelectSubscriptionOperationTests: XCTestCase {
    let validProducts = [
        VPseudoProduct(productIdentifier: "identifier1", price: "0.99", localizedDescription: "description1", localizedTitle: "title1"),
        VPseudoProduct(productIdentifier: "identifier2", price: "1.99", localizedDescription: "description2", localizedTitle: "title2"),
        VPseudoProduct(productIdentifier: "identifier3", price: "2.99", localizedDescription: "description3", localizedTitle: "title3")
    ]
    
    let invalidProducts = [
        VPseudoProduct(productIdentifier: "identifier1", price: nil, localizedDescription: "description1", localizedTitle: "title1"),
        VPseudoProduct(productIdentifier: "identifier2", price: "0.99", localizedDescription: nil, localizedTitle: "title1")
    ]
    
    func testValidProducts() {
        let operation = VIPSelectSubscriptionOperation(products: validProducts, originViewController: UIViewController(), dependencyManager: VDependencyManager(dictionary: ["key": "value"]))
        operation.execute { result in
            XCTFail("Operation execution finished unexpectedly without user interaction")
        }
    }
    
    func testInvalidProducts() {
        let operation = VIPSelectSubscriptionOperation(products: invalidProducts, originViewController: UIViewController(), dependencyManager: VDependencyManager(dictionary: ["key": "value"]))
        operation.execute { result in
            switch result {
                case .failure(let error as NSError):
                    XCTAssertEqual(error.code, -2)
                default:
                    XCTFail("Operation execution finished with unexpected result")
            }
        }
    }
}
