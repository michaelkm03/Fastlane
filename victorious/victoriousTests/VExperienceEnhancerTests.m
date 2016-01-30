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
#import "VVoteResult.h"
#import "NSObject+VMethodSwizzling.h"
#import "VLargeNumberFormatter.h"
#import "VAsyncTestHelper.h"
#import "OCMock.h"
#import "VApplicationTracking.h"

// TODO

static const NSUInteger kValidExperienceEnhancerCount = 9;
static const NSUInteger kExperienceEnhancerCount = 20;

@interface VApplicationTracking (UnitTests)

- (void)sendRequest:(NSURL *)url eventIndex:(NSInteger)eventIndex completion:(void(^)(NSError *))completion;

@end

@interface VExperienceEnhancer (UnitTests)

@property (nonatomic, assign) NSUInteger startingVoteCount;

@end

@interface VExperienceEnhancerController (UnitTests)

- (void)setExperienceEnhancers:(NSArray *)experienceEnhancers;

- (BOOL)updateExperience:(NSArray *)experienceEnhancers withSequence:(VSequence *)sequence;
- (NSArray *)createExperienceEnhancersFromVoteTypes:(NSArray *)voteTypes sequence:(VSequence *)sequence;

@end

@interface VExperienceEnhancerTests : XCTestCase

@property (nonatomic, retain) VExperienceEnhancerController *viewController;
@property (nonatomic, retain) NSArray *voteTypes;
@property (nonatomic, retain) VSequence *sequence;
@property (nonatomic, strong) VAsyncTestHelper *asyncHelper;

@end

@implementation VExperienceEnhancerTests

- (void)setUp
{
    [super setUp];
    
    self.asyncHelper = [[VAsyncTestHelper alloc] init];
    
    self.voteTypes = [VDummyModels createVoteTypes:kExperienceEnhancerCount];
    self.sequence = (VSequence *)[VDummyModels objectWithEntityName:@"Sequence" subclass:[VSequence class]];
    self.sequence.voteResults = [NSSet setWithArray:[VDummyModels createVoteResults:kExperienceEnhancerCount]];
    
    NSDictionary *configuration = @{ @"sequence" : self.sequence, @"voteTypes" : self.voteTypes };
    VDependencyManager *childDependencyManager = [[VDependencyManager alloc] initWithParentManager:nil configuration:configuration dictionaryOfClassesByTemplateName:nil];
    self.viewController = [[VExperienceEnhancerController alloc] initWithDependencyManager:childDependencyManager];
    VApplicationTracking *trackingManager = [[VApplicationTracking alloc] init];
    id myObjectMock = OCMPartialMock( trackingManager  );
    OCMStub( [myObjectMock sendRequest:OCMOCK_ANY eventIndex:1 completion:OCMOCK_ANY] );
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testCreateExperienceEnhancers
{
    NSArray *experienceEnhancers = [self.viewController createExperienceEnhancersFromVoteTypes:self.voteTypes sequence:self.sequence];
    XCTAssertEqual( experienceEnhancers.count, self.voteTypes.count );
}

- (void)testAddResults
{
    NSArray *experienceEnhancers = [self.viewController createExperienceEnhancersFromVoteTypes:self.voteTypes
                                                                                      sequence:self.sequence];
    
    self.viewController.experienceEnhancers = experienceEnhancers;
    [self.viewController updateData];
    
    __block NSUInteger matches = 0;
    NSMutableArray *array = [NSMutableArray new];
    [experienceEnhancers enumerateObjectsUsingBlock:^(VExperienceEnhancer *exp, NSUInteger idx, BOOL *stop)
     {
         [self.sequence.voteResults.allObjects enumerateObjectsUsingBlock:^(VVoteResult *result, NSUInteger idx, BOOL *stop)
          {
              if ( [[result.remoteId stringValue] isEqualToString:exp.voteType.voteTypeID ] )
              {
                  [array addObject:exp];
                  XCTAssertEqual( exp.voteCount, result.count.integerValue );
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
         NSUInteger start = exp.voteCount;
         
         // Set cooldown time to zero to test votes
         [exp setCooldownDuration:0];
         
         NSUInteger count = arc4random() % 200;
         for ( NSUInteger i = 0; i < count; i++ )
         {
             [exp vote];
         }
         
         NSInteger totalCount = start + count;
         XCTAssertEqual( exp.voteCount, totalCount );
         
     }];
}

- (void)testCoolDownTimers
{
    NSArray *experienceEnhancers = [self createExperienceEnhancers];
    
    [experienceEnhancers enumerateObjectsUsingBlock:^(VExperienceEnhancer *exp, NSUInteger idx, BOOL *stop)
     {
         XCTAssert([exp resetCooldownTimer]);
         
         exp.cooldownDuration = 10;
         
         NSUInteger count = arc4random() % 200;
         for ( NSUInteger i = 0; i < count; i++ )
         {
             [exp vote];
         }
         
         // Make sure vote count is one since cool down
         XCTAssertEqual( exp.voteCount, 1 );
         
     }];
    
    [experienceEnhancers enumerateObjectsUsingBlock:^(VExperienceEnhancer *exp, NSUInteger idx, BOOL *stop)
     {
         XCTAssert([exp resetCooldownTimer]);

         NSInteger startingVotes = exp.voteCount;
         NSTimeInterval cooldown = 0.2;
         NSTimeInterval timeUntilVote = cooldown + 0.2;
         
         // Set the cooldown time
         exp.cooldownDuration = cooldown;
         
         // Vote multiple times, should only register one
         NSUInteger count = 3;
         for ( NSUInteger i = 0; i < count; i++ )
         {
             [exp vote];
         }
         
         // Check if we're cooling down
         XCTAssertTrue(exp.isCoolingDown);
         
         XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
         
         // Wait out the cooldown time
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeUntilVote * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
         {
             XCTAssertTrue([exp ratioOfCooldownComplete] >= 1);
             XCTAssertTrue([exp secondsUntilCooldownIsOver] <= 0);
             
             // Vote again, should register now that cooldown is over
             [exp vote];
             XCTAssertEqual( exp.voteCount, startingVotes + 2 );
             [expectation fulfill];
         });
         
         [self waitForExpectationsWithTimeout:timeUntilVote + 1 handler:^(NSError *error)
         {
             if (error != nil)
             {
                 XCTFail(@"Error");
             }
         }];
     }];
}

@end
