//
//  VSettingManagerTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VSettingManager.h"
#import "VVoteType.h"
#import "VDummyModels.h"

@interface VSettingManagerTests : XCTestCase
{
    VSettingManager *_settingsManager;
}

@end

@implementation VSettingManagerTests

- (void)setUp
{
    [super setUp];
    
    _settingsManager = [VSettingManager sharedManager];
}

- (void)tearDown
{
    [super tearDown];
    
    [_settingsManager clearVoteTypes];
}

- (void)testVoteTypes
{
    NSArray *voteTypes = [VDummyModels createVoteTypes:5];
    [_settingsManager updateSettingsWithVoteTypes:voteTypes];
    XCTAssertEqual( _settingsManager.voteTypes.count, voteTypes.count );
}

- (void)testVoteTypesSortedByDisplayOrder
{
    NSArray *voteTypes = [VDummyModels createVoteTypes:5];
    voteTypes = @[ voteTypes[4],
                   voteTypes[3],
                   voteTypes[1],
                   voteTypes[0],
                   voteTypes[2] ];
    [_settingsManager updateSettingsWithVoteTypes:voteTypes];
    XCTAssertEqual( _settingsManager.voteTypes.count, voteTypes.count );
    
    [_settingsManager.voteTypes enumerateObjectsUsingBlock:^(VVoteType *voteType, NSUInteger i, BOOL *stop) {
        XCTAssertEqual( voteType.display_order, @(i+1) );
    }];
}

- (void)testVoteTypesFiltered
{
    NSArray *voteTypes = [VDummyModels createVoteTypes:5];
    NSArray *invalidObjects = @[ [NSObject new], [NSObject new], [NSObject new] ];
    NSArray *combined = [voteTypes arrayByAddingObjectsFromArray:invalidObjects];
    [_settingsManager updateSettingsWithVoteTypes:combined];
    XCTAssertEqual( _settingsManager.voteTypes.count, voteTypes.count );
}

- (void)testVoteTypesInvalid
{
    [_settingsManager updateSettingsWithVoteTypes:@[]];
    XCTAssertEqual( _settingsManager.voteTypes.count, (NSUInteger)0 );
    
    [_settingsManager updateSettingsWithVoteTypes:nil];
    XCTAssertEqual( _settingsManager.voteTypes.count, (NSUInteger)0 );
}

@end
