//
//  VDefaultProfileButton.h
//  victorious
//
//  Created by Will Long on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBadgeImageType.h"

@class VDependencyManager, VUser, AvatarLevelBadgeView;

NS_ASSUME_NONNULL_BEGIN

/**
 *  A UIButton showing a user avatar and, when able, a badge showing the level of the displayed user.
 *  It will default the profile image to the themed profile image.
 */
@interface VDefaultProfileButton : UIButton

/*
 *  Manually sets the image url loaded by this control in the given state.
 *  If the image load fails, the default profile image is used.
 *
 *  @param url The the url that will be loaded by this control.
 *  @param controlState The control state when this control will display the loaded image.
 */
- (void)setProfileImageURL:(NSURL *)url forState:(UIControlState)controlState;

/**
 *  Adds a border to this avatar with the provided width and color. This border is shown
 *  below the avatar level badge view.
 *
 *  @param width The width of the border to display around the avatar.
 *  @param color The color of the border to display around the avatar.
 */
- (void)addBorderWithWidth:(CGFloat)width andColor:(UIColor *)color;

/**
 *  The dependency manager used to style this control and create the avatar level badge view.
 */
@property (nonatomic, strong, nullable) VDependencyManager *dependencyManager;

/**
 *  The user whose level and avatar should be displayed in this control.
 *  Note that no level badge will be displayed if the dependency manager on this
 *  on this control cannot find a valid avatarLevelBadgeView.
 */
@property (nonatomic, strong, nullable) VUser *user;

/**
 *  The level badge image type of the avatar level badge shown on this control.
 *  Defaults to small.
 */
@property (nonatomic, assign) VLevelBadgeImageType levelBadgeImageType;

@property (nonatomic, strong) AvatarLevelBadgeView *levelBadgeView;

@end

NS_ASSUME_NONNULL_END
