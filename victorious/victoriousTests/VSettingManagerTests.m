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

@property (nonatomic, assign) IMP cacheVoteTypesImp;
@property (nonatomic, strong) VSettingManager *settingsManager;

@end

@implementation VSettingManagerTests

- (void)setUp
{
    [super setUp];
    
    self.cacheVoteTypesImp = nil;
    
    self.settingsManager = [VSettingManager sharedManager];
}

- (void)tearDown
{
    [super tearDown];
    
    if ( self.cacheVoteTypesImp != nil )
    {
        [VSettingManager v_restoreOriginalImplementation:self.cacheVoteTypesImp forMethod:@selector(cacheVoteTypeImagesWithFileCache:)];
    }
    
    [self.settingsManager clearVoteTypes];
}

- (void)swizzleCacheVotesMethod
{
    // Prevents images from being downloaded
    self.cacheVoteTypesImp = [VSettingManager v_swizzleMethod:@selector(cacheVoteTypeImagesWithFileCache:) withBlock:^{}];
}

- (void)testVoteTypes
{
    [self swizzleCacheVotesMethod];
    
    NSArray *voteTypes = [VDummyModels createVoteTypes:5];
    [self.settingsManager updateSettingsWithVoteTypes:voteTypes];
    XCTAssertEqual( self.settingsManager.voteTypes.count, voteTypes.count );
}

- (void)testVoteTypesFiltered
{
    [self swizzleCacheVotesMethod];
    
    NSArray *voteTypes = [VDummyModels createVoteTypes:5];
    NSArray *invalidObjects = @[ [NSObject new], [NSObject new], [NSObject new] ];
    NSArray *combined = [voteTypes arrayByAddingObjectsFromArray:invalidObjects];
    [self.settingsManager updateSettingsWithVoteTypes:combined];
    XCTAssertEqual( self.settingsManager.voteTypes.count, voteTypes.count );
}

- (void)testVoteTypesInvalid
{
    [self swizzleCacheVotesMethod];
    
    [self.settingsManager updateSettingsWithVoteTypes:@[]];
    XCTAssertEqual( self.settingsManager.voteTypes.count, (NSUInteger)0 );
    
    [self.settingsManager updateSettingsWithVoteTypes:nil];
    XCTAssertEqual( self.settingsManager.voteTypes.count, (NSUInteger)0 );
}

@end
