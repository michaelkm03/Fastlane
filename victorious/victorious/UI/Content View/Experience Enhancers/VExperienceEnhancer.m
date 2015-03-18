//
//  VExperienceEnhancer.m
//  victorious
//
//  Created by Michael Sena on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VExperienceEnhancer.h"
#import "VVoteType.h"
#import "VTracking.h"

@interface VExperienceEnhancer()

@property (nonatomic, assign) NSUInteger startingVoteCount;
@property (nonatomic, readwrite) VVoteType *voteType;
@property (nonatomic, readwrite) NSUInteger sessionVoteCount;

@end

@implementation VExperienceEnhancer

+ (NSArray *)experienceEnhancersSortedByDisplayOrder:(NSArray *)enhancers
{
    return [enhancers sortedArrayWithOptions:0
                            usingComparator:^NSComparisonResult(VExperienceEnhancer *exp1, VExperienceEnhancer *exp2)
            {
                return [exp1.voteType.displayOrder compare:exp2.voteType.displayOrder];
            }];
}

+ (NSArray *)experienceEnhancersFilteredByHasRequiredImages:(NSArray *)enhancers
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(VExperienceEnhancer *enhancer,
                                                                   NSDictionary *bindings)
                              {
                                  return enhancer.iconImage != nil;
                              }];
    return [enhancers filteredArrayUsingPredicate:predicate];
}

- (instancetype)initWithVoteType:(VVoteType *)voteType voteCount:(NSUInteger)voteCount
{
    self = [super init];
    if (self)
    {
        self.voteType = voteType;
        self.startingVoteCount = voteCount;
        
        self.contentMode = voteType.contentMode;
        self.flightDuration = (float)voteType.flightDuration.unsignedIntegerValue / 1000.0f;
        self.animationDuration = (float)voteType.animationDuration.unsignedIntegerValue / 1000.0f;
    }
    return self;
}

- (BOOL)isBallistic
{
    return self.flightDuration > 0.0;
}

- (void)vote
{
    self.sessionVoteCount++;
}

- (NSUInteger)totalVoteCount
{
    return self.sessionVoteCount + self.startingVoteCount;
}

- (void)resetSessionVoteCount
{
    self.sessionVoteCount = 0;
}

- (void)resetStartingVoteCount:(NSUInteger)voteCount
{
    self.startingVoteCount = voteCount;
}

- (NSArray *)trackingUrls
{
    return self.voteType.trackingURLs ?: @[];
}

@end
