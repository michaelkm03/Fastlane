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

static const NSUInteger kValidExperienceEnhancerCount = 10;
static const NSUInteger kExperienceEnhancerCount = 20;

@interface VExperienceEnhancerController (UnitTests)

@property (nonatomic, strong) NSArray *experienceEnhancers;

- (BOOL)addResultsFromSequence:(VSequence *)sequence toExperienceEnhancers:(NSArray *)experienceEnhancers;
- (NSArray *)createExperienceEnhancersFromVoteTypes:(NSArray *)voteTypes imageLoadedCallback:(void(^)())callback;

@property (nonatomic, strong) VFileCache *fileCache;

@end


@interface VExperienceEnhancerTests : XCTestCase

@property (nonatomic, retain) VExperienceEnhancerController *viewController;
@property (nonatomic, retain) NSArray *voteTypes;
@property (nonatomic, retain) VSequence *sequence;
@property (nonatomic, assign) IMP isImageCached;
@property (nonatomic, assign) IMP areSpriteImagesCached;
@property (nonatomic, retain) VLargeNumberFormatter *formatter;
@property (nonatomic, strong) VAsyncTestHelper *asyncHelper;

@end

@implementation VExperienceEnhancerTests

- (void)setUp
{
    [super setUp];
    
    self.formatter = [[VLargeNumberFormatter alloc] init];
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
}

- (void)tearDown
{
    [super tearDown];
    [VFileCache v_restoreOriginalImplementation:self.isImageCached forMethod:@selector(isImageCached:forVoteType:)];
    [VFileCache v_restoreOriginalImplementation:self.areSpriteImagesCached forMethod:@selector(areSpriteImagesCachedForVoteType:)];
}

- (void)testCreateExperienceEnhancers
{
    __block BOOL isImageCachedCalled = NO;
    NSArray *experienceEnhancers = [self.viewController createExperienceEnhancersFromVoteTypes:self.voteTypes imageLoadedCallback:^{
        isImageCachedCalled = YES;
    }];
    XCTAssertEqual( experienceEnhancers.count, self.voteTypes.count );
    [self.asyncHelper waitForSignal:5.0f withSignalBlock:^BOOL{
        return isImageCachedCalled;
    }];
}

- (void)testAddResults
{
    NSArray *experienceEnhancers = [self.viewController createExperienceEnhancersFromVoteTypes:self.voteTypes imageLoadedCallback:nil];
    [self.viewController addResultsFromSequence:self.sequence toExperienceEnhancers:experienceEnhancers];
    
    __block NSUInteger matches = 0;
    [experienceEnhancers enumerateObjectsUsingBlock:^(VExperienceEnhancer *exp, NSUInteger idx, BOOL *stop)
     {
         [self.sequence.voteResults.allObjects enumerateObjectsUsingBlock:^(VVoteResult *result, NSUInteger idx, BOOL *stop)
          {
              if ( [result.remoteId isEqual:exp.voteType.remoteId] )
              {
                  XCTAssertEqualObjects( exp.labelText, [self.formatter stringForInteger:result.count.integerValue] );
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
        VExperienceEnhancer *enhancer = [[VExperienceEnhancer alloc] initWithVoteType:voteType];
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
    
    experienceEnhancers = [VExperienceEnhancer experienceEnhancersFilteredByHasRequiredImages:experienceEnhancers];
    
    XCTAssertEqual( experienceEnhancers.count, kValidExperienceEnhancerCount );
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

@end
