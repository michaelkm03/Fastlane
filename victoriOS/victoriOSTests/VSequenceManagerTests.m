//
//  VSequenceManagerTests.m
//  victoriOS
//
//  Created by David Keegan on 12/9/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VAPIManager.h"
#import "VSequenceManager.h"

@interface VSequenceManagerTests : XCTestCase

@end

@implementation VSequenceManagerTests

- (void)setUp
{
    [super setUp];

    [VAPIManager setupRestKit];    
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

//+ (void)loadSequenceCategories;
//+ (void)loadFullDataForSequence:(VSequence*)sequence;
//+ (void)loadCommentsForSequence:(VSequence*)sequence;
//
//+ (void)loadStatSequencesForUser:(VUser*)user;
//+ (void)loadFullDataForStatSequence:(VStatSequence*)statSequence;
//
//+ (void)createStatSequenceForSequence:(VSequence*)sequence;
//+ (void)addStatInterationToStatSequence:(VStatSequence*)sequence;
//+ (void)addStatAnswerToStatInteraction:(VStatInteraction*)interaction;

- (void)testLoadSequenceCategories
{
    [VSequenceManager loadSequenceCategories];
}

@end
