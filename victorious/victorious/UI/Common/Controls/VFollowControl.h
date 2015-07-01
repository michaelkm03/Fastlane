//
//  VFollowControl.h
//  victorious
//
//  Created by Sharif Ahmed on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VDependencyManager;

@interface VFollowControl : UIControl

- (void)setFollowing:(BOOL)following animated:(BOOL)animated;
- (void)setFollowing:(BOOL)following animated:(BOOL)animated withAnimationBlock:(void (^)(void))animationBlock;

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, assign, getter = isFollowing) BOOL following;

@end