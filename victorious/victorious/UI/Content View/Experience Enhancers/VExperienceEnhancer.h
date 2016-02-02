//
//  VExperienceEnhancer.h
//  victorious
//
//  Created by Michael Sena on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VVoteType;

@interface VExperienceEnhancer : NSObject

/**
 Sorts according to display order of the voteType used to create
 the experience enhancer.
 */
+ (NSArray *)experienceEnhancersSortedByDisplayOrder:(NSArray *)enhancers;

/**
 Filters out any experience enhancers from the enhancers array that do not
 have the images loaded that are required for display.
 */
+ (NSArray *)experienceEnhancersFilteredByHasRequiredImages:(NSArray *)enhancers;

- (instancetype)initWithVoteType:(VVoteType *)voteType voteCount:(NSUInteger)voteCount;

/**
 Intended to be called when experience enhancer is interacted with by user.
 Increments the sessionVoteCount and totalVoteCount.
 */
- (BOOL)vote;

@property (nonatomic, strong, readonly) NSArray *trackingUrls;

@property (nonatomic, assign) BOOL requiresPurchase;
@property (nonatomic, assign) BOOL requiresHigherLevel;

@property (nonatomic, assign) NSInteger voteCount;

@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign) NSTimeInterval flightDuration;
@property (nonatomic, assign) NSTimeInterval cooldownDuration; // <- in seconds
@property (nonatomic, readonly) VVoteType *voteType;
@property (nonatomic, readonly) BOOL isBallistic;
@property (nonatomic, readonly) NSDate *lastVoted;
@property (nonatomic, readonly) NSDate *cooldownDate;

/**
 Determines if this experience enhancer is in the process
 of cooling down
 */
- (BOOL)isCoolingDown;

/**
 A float between 0 and 1 representing how much of the cooldown
 has been completed
 */
- (CGFloat)ratioOfCooldownComplete;

/**
 Number of seconds until cooldown is complete
 */
- (NSTimeInterval)secondsUntilCooldownIsOver;

/**
 Removes the cached last vote date for this experience enhancer
 which will void the current cooldown period if there is one
 
 @returns YES if cooldown timer was successfully reset
 */
- (BOOL)resetCooldownTimer;

@end
