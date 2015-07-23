//
//  VExperienceEnhancerCell.h
//  victorious
//
//  Created by Michael Sena on 10/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@class VDependencyManager;

@interface VExperienceEnhancerCell : VBaseCollectionViewCell

@property (nonatomic, copy) NSString *experienceEnhancerTitle;
@property (nonatomic, strong) UIImage *experienceEnhancerIcon;
@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, assign) CGFloat cooldownStartValue;
@property (nonatomic, assign) CGFloat cooldownEndValue;
@property (nonatomic, assign) NSTimeInterval cooldownDuration;

- (void)startCooldown;

@end
