//
//  VExperienceEnhancerCell.h
//  victorious
//
//  Created by Michael Sena on 10/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@class VDependencyManager;

/**
 *  A key to use to determine whether or not to show EB counts.
 */
extern NSString * const VExperienceEnhancerCellShouldShowCountKey;

@interface VExperienceEnhancerCell : VBaseCollectionViewCell

@property (nonatomic, copy) NSString *experienceEnhancerTitle;
@property (nonatomic, strong) UIImage *experienceEnhancerIcon;
@property (nonatomic, assign) BOOL requiresPurchase;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, assign) CGFloat cooldownStartValue;
@property (nonatomic, assign) CGFloat cooldownEndValue;
@property (nonatomic, assign) NSTimeInterval cooldownDuration;

- (void)startCooldown;

/**
 Update whether to lock the emotive ballsitic or not, based on
 the unlockLevel of EB and the current level of user
 
 @param unlockLevel The level at which this EB should be unlocked
 @param userLevel The current level the user is at
 */
- (void)updateLevelLockingStatusWithUnlockLevel:(NSInteger)unlockLevel andUserLevel:(NSInteger)userLevel;

@end
