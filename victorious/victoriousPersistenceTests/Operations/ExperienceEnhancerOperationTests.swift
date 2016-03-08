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
        let voteTypes: [VVoteType] = []
        let operation = ExperienceEnhancersOperation(sequence: sequence, voteTypes: voteTypes)
        let expectation = expectationWithDescription("ExperienceEnhancersOperation")

        operation.queue() { results in

            XCTAssertNotNil(operation.experienceEnhancers)
            XCTAssertEqual(operation.experienceEnhancers?.count, 0)
            
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler:nil)
    }
    
    func testMultipleVoteTypes() {
        var voteTypes: [String: VVoteType] = [:]
        for voteTypeID in 0..<10 {
            let voteTypeDependencyManager = VDependencyManager(parentManager: nil,
                                    configuration: [
                                        "flightDuration"    : 3*voteTypeID,
                                        "animationDuration" : 3*voteTypeID+1,
                                        "cooldownDuration"  : 3*voteTypeID+2,
                                        "icon"              : UIImage(),
                                        "voteTypeID"        : "\(voteTypeID)"
                                        
                ],
                dictionaryOfClassesByTemplateName: nil)
            
            let voteType = VVoteType(dependencyManager: voteTypeDependencyManager)
            voteTypes[String(voteTypeID)] = voteType
        }
        
        let operation = ExperienceEnhancersOperation(sequence: sequence, voteTypes: Array(voteTypes.values))
        let expectation = expectationWithDescription("ExperienceEnhancersOperation")
        
        operation.queue() { results in
            guard let experienceEnhancers: [VExperienceEnhancer] = operation.experienceEnhancers else {
                XCTFail("Experience Enhancers should not be nil")
                return
            }
            
            // Check number of Experience Enhancers
            XCTAssertEqual(operation.experienceEnhancers?.count, voteTypes.count)
            
            for experienceEnhancer in experienceEnhancers {
                let voteTypeID = experienceEnhancer.voteType.voteTypeID
                guard let voteType = voteTypes[voteTypeID] else {
                    XCTFail("Vote type \(voteTypeID) not found")
                    return
                }
                
                XCTAssertEqual(experienceEnhancer.voteType, voteType)
                XCTAssertEqual(experienceEnhancer.iconImage, voteType.iconImage)
                XCTAssertEqual(experienceEnhancer.voteCount, Int(voteType.voteTypeID))
                
                XCTAssertEqual(experienceEnhancer.cooldownDuration, Double(voteType.cooldownDuration.doubleValue/1000))
                XCTAssertEqual(experienceEnhancer.flightDuration, Double(voteType.flightDuration.floatValue/1000))
                XCTAssertEqual(experienceEnhancer.animationDuration, Double(voteType.animationDuration.floatValue/1000))
            }
            
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler:nil)
    }
    
}
