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
    var sequence: VSequence?
    var sequenceVoteTypes: [VVoteResult] = []
    
    override func setUp() {
        super.setUp()
        sequence = persistentStoreHelper.createSequence(remoteId: sequenceID)
        guard let sequence = sequence else {
            return
        }
        // Skipping ID = 0, no results for ID = 1
        for a in 1..<20 {
            let voteResult = persistentStoreHelper.createVoteResult(sequence, count: a, remoteId: a)
            sequenceVoteTypes.append(voteResult)
        }
        sequence.voteResults = NSSet(array: sequenceVoteTypes) as Set<NSObject>
    }
    
    func testEmptyVoteTypes() {
        let voteTypes: [VVoteType] = []
        guard let sequence = sequence else {
            XCTFail("Sequence cannot be nil")
            return
        }
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
        for a in 0..<10 {
            let voteTypeDependencyManager = VDependencyManager(parentManager: nil,
                                    configuration: [
                                        "flightDuration"    : 3*a,
                                        "animationDuration" : 3*a+1,
                                        "cooldownDuration"  : 3*a+2,
                                        "icon"              : UIImage(),
                                        "voteTypeID"        : "\(a)"
                                        
                ],
                dictionaryOfClassesByTemplateName: nil)
            
            let voteType = VVoteType(dependencyManager: voteTypeDependencyManager)
            voteTypes[String(a)] = voteType
        }
        
        guard let sequence = sequence else {
            XCTFail("Sequence cannot be nil")
            return
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
                    continue
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
