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
#import "NSObject+VMethodSwizzling.h"
#import "VFileCache.h"

@interface VSettingManager()

- (void)cacheVoteTypeImagesWithFileCache:(VFileCache *)fileCache;

@end

@interface VSettingManagerTests : XCTestCase
{
    IMP cacheVoteTypesImp;
    VSettingManager *_settingsManager;
}

@end

@implementation VSettingManagerTests

- (void)setUp
{
    [super setUp];
    
    cacheVoteTypesImp = nil;
    
    _settingsManager = [VSettingManager sharedManager];
}

- (void)tearDown
{
    [super tearDown];
    
    if ( cacheVoteTypesImp != nil )
    {
        [VSettingManager v_restoreOriginalImplementation:cacheVoteTypesImp forMethod:@selector(cacheVoteTypeImagesWithFileCache:)];
    }
    
    [_settingsManager clearVoteTypes];
}

- (void)swizzleCacheVotesMethod
{
    // Prevents images from being downloaded
    cacheVoteTypesImp = [VSettingManager v_swizzleMethod:@selector(cacheVoteTypeImagesWithFileCache:) withBlock:^{}];
}

- (void)testVoteTypes
{
    [self swizzleCacheVotesMethod];
    
    NSArray *voteTypes = [VDummyModels createVoteTypes:5];
    [_settingsManager updateSettingsWithVoteTypes:voteTypes];
    XCTAssertEqual( _settingsManager.voteTypes.count, voteTypes.count );
}

- (void)testVoteTypesSortedByDisplayOrder
{
    [self swizzleCacheVotesMethod];
    
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
    [self swizzleCacheVotesMethod];
    
    NSArray *voteTypes = [VDummyModels createVoteTypes:5];
    NSArray *invalidObjects = @[ [NSObject new], [NSObject new], [NSObject new] ];
    NSArray *combined = [voteTypes arrayByAddingObjectsFromArray:invalidObjects];
    [_settingsManager updateSettingsWithVoteTypes:combined];
    XCTAssertEqual( _settingsManager.voteTypes.count, voteTypes.count );
}

- (void)testVoteTypesInvalid
{
    [self swizzleCacheVotesMethod];
    
    [_settingsManager updateSettingsWithVoteTypes:@[]];
    XCTAssertEqual( _settingsManager.voteTypes.count, (NSUInteger)0 );
    
    [_settingsManager updateSettingsWithVoteTypes:nil];
    XCTAssertEqual( _settingsManager.voteTypes.count, (NSUInteger)0 );
}

@end
