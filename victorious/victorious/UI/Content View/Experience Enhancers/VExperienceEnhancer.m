//
//  VExperienceEnhancer.m
//  victorious
//
//  Created by Michael Sena on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VExperienceEnhancer.h"
#import "VVoteType.h"
#import "victorious-Swift.h"

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
        
        _flightDuration = (NSTimeInterval)voteType.flightDuration.doubleValue / 1000.0f;
        _animationDuration = (NSTimeInterval)voteType.animationDuration.doubleValue / 1000.0f;
        _cooldownDuration = (NSTimeInterval)voteType.cooldownDuration.doubleValue / 1000.0f;
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
        [userDefaults setObject:[NSDate date] forKey:[self coolDownPersistenceKey]];
        [userDefaults synchronize];
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
    NSDate *lastVoted = [userDefaults objectForKey:[self coolDownPersistenceKey]];
    return lastVoted;
}

- (NSTimeInterval)secondsUntilCooldownIsOver
{
    return self.cooldownDuration - [self secondsSinceLastVote];
}

- (CGFloat)ratioOfCooldownComplete
{
    return [self secondsSinceLastVote] / self.cooldownDuration;
}

- (NSDate *)cooldownDate
{
    return [self.lastVoted dateByAddingTimeInterval:self.cooldownDuration];
}

- (NSTimeInterval)secondsSinceLastVote
{
    NSDate *now = [NSDate date];
    return [now timeIntervalSince1970] - [[self lastVoted] timeIntervalSince1970];
}

- (NSString *)coolDownPersistenceKey
{
    return [@"cooldown-" stringByAppendingString:self.voteType.voteTypeID];
}

- (BOOL)resetCooldownTimer
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:[self coolDownPersistenceKey]];
    return [userDefaults synchronize];
}

@end
