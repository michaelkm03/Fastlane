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

@interface VExperienceEnhancerController (UnitTests)

@property (nonatomic, strong) NSArray *experienceEnhancers;

- (BOOL)addResultsFromSequence:(VSequence *)sequence toExperienceEnhancers:(NSArray *)experienceEnhancers;
- (NSArray *)createExperienceEnhancersFromVoteTypes:(NSArray *)voteTypes;

@property (nonatomic, strong) VFileCache *fileCache;

@end


@interface VExperienceEnhancerTests : XCTestCase

@property (nonatomic, retain) VExperienceEnhancerController *viewController;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, retain) NSArray *voteTypes;
@property (nonatomic, retain) VSequence *sequence;
@property (nonatomic, assign) IMP isImageCached;
@property (nonatomic, assign) IMP areSpriteImagesCached;
@property (nonatomic, retain) VLargeNumberFormatter *formatter;

@end

@implementation VExperienceEnhancerTests

- (void)setUp
{
    [super setUp];
    
    self.count = 5;
    
    self.formatter = [[VLargeNumberFormatter alloc] init];
    
    self.isImageCached = [VFileCache v_swizzleMethod:@selector(isImageCached:forVoteType:) withBlock:^BOOL
                         {
                             return YES;
                         }];
    
    self.areSpriteImagesCached = [VFileCache v_swizzleMethod:@selector(areSpriteImagesCachedForVoteType:) withBlock:^BOOL
                                 {
                                     return YES;
                                 }];
    
    self.voteTypes = [VDummyModels createVoteTypes:self.count];
    self.sequence = (VSequence *)[VDummyModels objectWithEntityName:@"Sequence" subclass:[VSequence class]];
    self.sequence.voteResults = [NSSet setWithArray:[VDummyModels createVoteResults:self.count]];
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
    NSArray *experienceEnhancers = [self.viewController createExperienceEnhancersFromVoteTypes:self.voteTypes];
    XCTAssertEqual( experienceEnhancers.count, self.voteTypes.count );
}

- (void)testAddResults
{
    NSArray *experienceEnhancers = [self.viewController createExperienceEnhancersFromVoteTypes:self.voteTypes];
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

@end
