//
//  ExperienceEnhancerOperationTests.swift
//  victorious
//
//  Created by Vincent Ho on 3/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class ExperienceEnhancerOperationTests: BaseFetcherOperationTestCase {

    let sequenceID = "12345"
    var sequence: VSequence!
    var sequenceVoteTypes: [VVoteResult] = []
    private var mockProductsDataSource = MockVoteTypesDataSource()
    
    override func setUp() {
        super.setUp()
        sequence = persistentStoreHelper.createSequence(remoteId: sequenceID)
        // Skipping ID = 0, no results for ID = 1
        for voteResultRemoteId in 1..<20 {
            let voteResult = persistentStoreHelper.createVoteResult(sequence, count: voteResultRemoteId, remoteId: voteResultRemoteId)
            sequenceVoteTypes.append(voteResult)
        }
        sequence.voteResults = NSSet(array: sequenceVoteTypes) as Set<NSObject>
    }
    
    func testEmptyVoteTypes() {
        mockProductsDataSource.voteTypes = []
        let operation = ExperienceEnhancersOperation(sequenceID: sequence.remoteId, productsDataSource: mockProductsDataSource)
        let expectation = expectationWithDescription("ExperienceEnhancersOperation")

        operation.queue() { results, error, cancelled in

            XCTAssertNotNil(results)
            XCTAssertEqual(results?.count, 0)
            
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
    
    func testMultipleVoteTypes() {
        var voteTypes: [String: VVoteType] = [:]
        for voteTypeID in 0..<10 {
            let voteTypeDependencyManager = VDependencyManager(parentManager: nil,
                                    configuration: [
                                        "flightDuration": 3 * voteTypeID,
                                        "animationDuration": 3 * voteTypeID + 1,
                                        "cooldownDuration": 3 * voteTypeID + 2,
                                        "icon": UIImage(),
                                        "voteTypeID": "\(voteTypeID)"
                ],
                dictionaryOfClassesByTemplateName: nil)
            
            let voteType = VVoteType(dependencyManager: voteTypeDependencyManager)
            voteTypes[String(voteTypeID)] = voteType
        }
        
        mockProductsDataSource.voteTypes = Array(voteTypes.values)
        let operation = ExperienceEnhancersOperation(sequenceID: sequence.remoteId, productsDataSource: mockProductsDataSource)
        let expectation = expectationWithDescription("ExperienceEnhancersOperation")
        
        operation.queue() { results, error, cancelled in
            guard let experienceEnhancers = operation.results as? [VExperienceEnhancer] else {
                XCTFail("Experience Enhancers should not be nil")
                return
            }
            
            // Check number of Experience Enhancers
            XCTAssertEqual(results?.count, self.mockProductsDataSource.voteTypes.count)
            
            for experienceEnhancer in experienceEnhancers {
                let voteTypeID = experienceEnhancer.voteType.voteTypeID
                guard let voteType = voteTypes[voteTypeID] else {
                    XCTFail("Vote type \(voteTypeID) not found")
                    return
                }
                
                XCTAssertEqual(experienceEnhancer.voteType, voteType)
                XCTAssertEqual(experienceEnhancer.iconImage, voteType.iconImage)
                XCTAssertEqual(experienceEnhancer.voteCount, Int(voteType.voteTypeID))
                
                XCTAssertEqualWithAccuracy(experienceEnhancer.cooldownDuration, voteType.cooldownDuration.doubleValue / 1000.0, accuracy: DBL_EPSILON)
                XCTAssertEqualWithAccuracy(experienceEnhancer.flightDuration, voteType.flightDuration.doubleValue / 1000.0, accuracy: DBL_EPSILON)
                XCTAssertEqualWithAccuracy(experienceEnhancer.animationDuration, voteType.animationDuration.doubleValue / 1000.0, accuracy: DBL_EPSILON)
            }
            
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
}

class MockVoteTypesDataSource: NSObject, TemplateProductsDataSource {
    
    var vipSubscription: Subscription? {
        abort()
    }
    
    var productIdentifiersForVoteTypes: [String] {
        abort()
    }
    
    func voteTypeForProductIdentifier(productIdentifier: String) -> VVoteType? {
        abort()
    }
    
    var voteTypes = [VVoteType]()
}
