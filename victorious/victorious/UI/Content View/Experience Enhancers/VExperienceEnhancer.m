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

@property (nonatomic, readwrite) VVoteType *voteType;

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
        _voteType = voteType;
        _voteCount = voteCount;
        
        _contentMode = voteType.contentMode;
        _flightDuration = (float)voteType.flightDuration.unsignedIntegerValue / 1000.0f;
        _animationDuration = (float)voteType.animationDuration.unsignedIntegerValue / 1000.0f;
        _cooldownDuration = (double)voteType.cooldownDuration.unsignedIntegerValue / 1000.0f;
    }
    return self;
}

- (BOOL)isBallistic
{
    return self.flightDuration > 0.0;
}

- (NSArray *)trackingUrls
{
    return self.voteType.trackingURLs ?: @[];
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"%@: %p: %@ (%ld)", NSStringFromClass([self class]), self, self.voteType.voteTypeName, (long)self.voteCount];
}

#pragma mark - Voting

- (BOOL)vote
{
    if ( ![self isCoolingDown] )
    {
        self.voteCount++;
        
        // Save date that we last voted
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[NSDate date] forKey:self.voteType.voteTypeID];
        return YES;
    }
    
    return NO;
}

- (BOOL)isCoolingDown
{
    return [self secondsUntilCooldownIsOver] > 0;
}

- (NSDate *)lastVoted
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastVoted = [userDefaults objectForKey:self.voteType.voteTypeID];
    return lastVoted;
}

- (NSTimeInterval)secondsUntilCooldownIsOver
{
    return self.cooldownDuration - [self secondsSinceLastVote];
}

- (CGFloat)percentageOfCooldownComplete
{
    return [self secondsSinceLastVote] / self.cooldownDuration;
}

- (NSTimeInterval)secondsSinceLastVote
{
    NSDate *now = [NSDate date];
    return [now timeIntervalSince1970] - [[self lastVoted] timeIntervalSince1970];
}

@end
