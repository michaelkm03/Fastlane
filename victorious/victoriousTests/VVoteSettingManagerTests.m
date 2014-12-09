//
//  VVoteSettingManagerTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VVoteSettings.h"
#import "VVoteType.h"
#import "VDummyModels.h"
#import "NSObject+VMethodSwizzling.h"
#import "VFileCache.h"

@interface VVoteSettings()

- (void)cacheVoteTypeImagesWithFileCache:(VFileCache *)fileCache;

@end

@interface VVoteSettingManagerTests : XCTestCase

@property (nonatomic, assign) IMP cacheVoteTypesImp;
@property (nonatomic, strong) VVoteSettings *settings;

@end

@implementation VVoteSettingManagerTests

- (void)setUp
{
    [super setUp];
    
    self.cacheVoteTypesImp = nil;
    
    self.settings = [[VVoteSettings alloc] init];
}

- (void)tearDown
{
    [super tearDown];
    
    if ( self.cacheVoteTypesImp != nil )
    {
        [VVoteSettings v_restoreOriginalImplementation:self.cacheVoteTypesImp forMethod:@selector(cacheVoteTypeImagesWithFileCache:)];
    }
}

- (void)swizzleCacheVotesMethod
{
    // Prevents images from being downloaded
    self.cacheVoteTypesImp = [VVoteSettings v_swizzleMethod:@selector(cacheVoteTypeImagesWithFileCache:) withBlock:^{}];
}

- (void)testVoteTypes
{
    [self swizzleCacheVotesMethod];
    
    NSArray *voteTypes = [VDummyModels createVoteTypes:5];
    self.settings.voteTypes = voteTypes;
    XCTAssertEqual( self.settings.voteTypes.count, voteTypes.count );
}

- (void)testVoteTypesFiltered
{
    [self swizzleCacheVotesMethod];
    
    NSArray *voteTypes = [VDummyModels createVoteTypes:5];
    NSArray *invalidObjects = @[ [NSObject new], [NSObject new], [NSObject new] ];
    NSArray *combined = [voteTypes arrayByAddingObjectsFromArray:invalidObjects];
    self.settings.voteTypes = combined;
    XCTAssertEqual( self.settings.voteTypes.count, voteTypes.count );
}

- (void)testVoteTypesInvalid
{
    [self swizzleCacheVotesMethod];
    
    self.settings.voteTypes = @[];
    XCTAssertEqual( self.settings.voteTypes.count, (NSUInteger)0 );
    
    self.settings.voteTypes = nil;
    XCTAssertEqual( self.settings.voteTypes.count, (NSUInteger)0 );
}

@end
