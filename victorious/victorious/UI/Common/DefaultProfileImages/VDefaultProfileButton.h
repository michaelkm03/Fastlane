//
//  VDefaultProfileButton.h
//  victorious
//
//  Created by Will Long on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBadgeImageType.h"

@class VDependencyManager, VUser;

NS_ASSUME_NONNULL_BEGIN

/**
 *  A UIButton for profiles.  It will default the profile image to the themed profile image.
 */
@interface VDefaultProfileButton : UIButton


- (void)setProfileImageURL:(NSURL *)url forState:(UIControlState)controlState;

- (void)addBorderWithWidth:(CGFloat)width andColor:(UIColor *)color;

@property (nonatomic, strong, nullable) VDependencyManager *dependencyManager;

@property (nonatomic, strong, nullable) VUser *user;

@property (nonatomic, assign) VLevelBadgeImageType levelBadgeImageType;

@end

NS_ASSUME_NONNULL_END
