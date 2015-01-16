//
//  VExperienceEnhancerTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VDummyModels.h"
#import "VSequence.h"
#import "VExperienceEnhancer.h"
#import "VExperienceEnhancerController.h"
#import "VFileCache.h"
#import "VVoteResult.h"
#import "VFileCache+VVoteType.h"
#import "NSObject+VMethodSwizzling.h"
#import "VLargeNumberFormatter.h"
#import "VAsyncTestHelper.h"
#import "OCMock.h"
#import "VApplicationTracking.h"

static const NSUInteger kValidExperienceEnhancerCount = 10;
static const NSUInteger kExperienceEnhancerCount = 20;

@interface VApplicationTracking (UnitTests)

- (void)sendRequest:(NSURLRequest *)request;

@end

@interface VExperienceEnhancer (UnitTests)

@property (nonatomic, assign) NSUInteger startingVoteCount;

@end

@interface VExperienceEnhancerController (UnitTests)

@property (nonatomic, strong) NSArray *experienceEnhancers;
@property (nonatomic, strong) VFileCache *fileCache;

- (BOOL)updateExperience:(NSArray *)experienceEnhancers withSequence:(VSequence *)sequence;
- (NSArray *)createExperienceEnhancersFromVoteTypes:(NSArray *)voteTypes sequence:(VSequence *)sequence;

@end


@interface VExperienceEnhancerTests : XCTestCase

@property (nonatomic, retain) VExperienceEnhancerController *viewController;
@property (nonatomic, retain) NSArray *voteTypes;
@property (nonatomic, retain) VSequence *sequence;
@property (nonatomic, assign) IMP isImageCached;
@property (nonatomic, assign) IMP areSpriteImagesCached;
@property (nonatomic, strong) VAsyncTestHelper *asyncHelper;

@end

@implementation VExperienceEnhancerTests

- (void)setUp
{
    [super setUp];
    
    self.asyncHelper = [[VAsyncTestHelper alloc] init];
    
    self.isImageCached = [VFileCache v_swizzleMethod:@selector(isImageCached:forVoteType:) withBlock:^BOOL
                         {
                             return YES;
                         }];
    
    self.areSpriteImagesCached = [VFileCache v_swizzleMethod:@selector(areSpriteImagesCachedForVoteType:) withBlock:^BOOL
                                 {
                                     return YES;
                                 }];
    
    self.voteTypes = [VDummyModels createVoteTypes:kExperienceEnhancerCount];
    self.sequence = (VSequence *)[VDummyModels objectWithEntityName:@"Sequence" subclass:[VSequence class]];
    self.sequence.voteResults = [NSSet setWithArray:[VDummyModels createVoteResults:kExperienceEnhancerCount]];
    
    self.viewController = [[VExperienceEnhancerController alloc] initWithSequence:self.sequence];
    VApplicationTracking *trackingManager = [[VApplicationTracking alloc] init];
    id myObjectMock = OCMPartialMock( trackingManager  );
    OCMStub( [myObjectMock sendRequest:[OCMArg any]] );
}

- (void)tearDown
{
    [super tearDown];
    [VFileCache v_restoreOriginalImplementation:self.isImageCached forMethod:@selector(isImageCached:forVoteType:)];
    [VFileCache v_restoreOriginalImplementation:self.areSpriteImagesCached forMethod:@selector(areSpriteImagesCachedForVoteType:)];
}

- (void)testCreateExperienceEnhancers
{
    NSArray *experienceEnhancers = [self.viewController createExperienceEnhancersFromVoteTypes:self.voteTypes sequence:self.sequence];
    XCTAssertEqual( experienceEnhancers.count, self.voteTypes.count );
}

- (void)testAddResults
{
    NSArray *experienceEnhancers = [self.viewController createExperienceEnhancersFromVoteTypes:self.voteTypes sequence:self.sequence];
    
    [self.viewController updateExperience:experienceEnhancers withSequence:self.sequence];
    
    __block NSUInteger matches = 0;
    [experienceEnhancers enumerateObjectsUsingBlock:^(VExperienceEnhancer *exp, NSUInteger idx, BOOL *stop)
     {
         [self.sequence.voteResults.allObjects enumerateObjectsUsingBlock:^(VVoteResult *result, NSUInteger idx, BOOL *stop)
          {
              if ( [result.remoteId isEqual:exp.voteType.remoteId] )
              {
                  XCTAssertEqual( exp.startingVoteCount, result.count.unsignedIntegerValue );
                  matches++;
              }
          }];
     }];
    
    XCTAssertEqual( matches, experienceEnhancers.count );
}

- (NSArray *)createExperienceEnhancers
{
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    [self.voteTypes enumerateObjectsUsingBlock:^(VVoteType *voteType, NSUInteger idx, BOOL *stop) {
        VExperienceEnhancer *enhancer = [[VExperienceEnhancer alloc] initWithVoteType:voteType voteCount:0];
        enhancer.voteType.displayOrder = @( arc4random() % self.voteTypes.count );
        if ( idx < kValidExperienceEnhancerCount )
        {
            enhancer.iconImage = [UIImage new];
            enhancer.animationSequence = @[ [UIImage new], [UIImage new], [UIImage new], [UIImage new] ];
        }
        [mutableArray addObject:enhancer];
    }];
    XCTAssertNotEqual( mutableArray.count, (NSUInteger)0 );
    return [NSArray arrayWithArray:mutableArray];
}

- (void)testFilter
{
    NSArray *experienceEnhancers = [self createExperienceEnhancers];
    NSArray *filtered = nil;
    
    filtered = [VExperienceEnhancer experienceEnhancersFilteredByHasRequiredImages:experienceEnhancers];
    XCTAssertEqual( filtered.count, kValidExperienceEnhancerCount );
    
    ((VExperienceEnhancer *)experienceEnhancers.firstObject).animationSequence = nil;
    filtered = [VExperienceEnhancer experienceEnhancersFilteredByHasRequiredImages:experienceEnhancers];
    XCTAssertEqual( filtered.count, kValidExperienceEnhancerCount );
    
    ((VExperienceEnhancer *)experienceEnhancers[0]).iconImage = nil;
    filtered = [VExperienceEnhancer experienceEnhancersFilteredByHasRequiredImages:experienceEnhancers];
    XCTAssertEqual( filtered.count, kValidExperienceEnhancerCount-1 );
    
    ((VExperienceEnhancer *)experienceEnhancers[0]).iconImage = nil;
    ((VExperienceEnhancer *)experienceEnhancers[1]).iconImage = nil;
    filtered = [VExperienceEnhancer experienceEnhancersFilteredByHasRequiredImages:experienceEnhancers];
    XCTAssertEqual( filtered.count, kValidExperienceEnhancerCount-2 );
}

- (void)testSortByDisplayOrder
{
    NSArray *experienceEnhancers = [self createExperienceEnhancers];
    
    experienceEnhancers = [VExperienceEnhancer experienceEnhancersSortedByDisplayOrder:experienceEnhancers];
    for ( NSUInteger i = 1; i < experienceEnhancers.count; i++ )
    {
        VExperienceEnhancer *prev = experienceEnhancers[i-1];
        VExperienceEnhancer *current = experienceEnhancers[i];
        XCTAssert( prev.voteType.displayOrder.integerValue <= current.voteType.displayOrder.integerValue );
    }
}

- (void)testVoteCounts
{
    NSArray *experienceEnhancers = [self createExperienceEnhancers];
    
    [experienceEnhancers enumerateObjectsUsingBlock:^(VExperienceEnhancer *exp, NSUInteger idx, BOOL *stop)
     {
         NSUInteger start = arc4random() % 200;
         [exp resetStartingVoteCount:start];
         
         NSUInteger count = arc4random() % 200;
         for ( NSUInteger i = 0; i < count; i++ )
         {
             [exp vote];
         }
         
         XCTAssertEqual( exp.totalVoteCount, start + count );
         
         [exp resetSessionVoteCount];
         XCTAssertEqual( exp.totalVoteCount, start );
         XCTAssertEqual( exp.sessionVoteCount, (NSUInteger)0 );
         
     }];
}

@end
