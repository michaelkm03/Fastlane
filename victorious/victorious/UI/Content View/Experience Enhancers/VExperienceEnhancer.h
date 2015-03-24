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
- (void)vote;

@property (nonatomic, strong, readonly) NSArray *trackingUrls;

@property (nonatomic, assign) BOOL isLocked;

@property (nonatomic, assign) NSInteger voteCount;

@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) NSArray *animationSequence;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign) NSTimeInterval flightDuration;
@property (nonatomic, strong) UIImage *flightImage;
@property (nonatomic, assign) UIViewContentMode contentMode;
@property (nonatomic, readonly) VVoteType *voteType;
@property (nonatomic, readonly) BOOL isBallistic;

@end
