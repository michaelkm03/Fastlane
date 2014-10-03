//
//  VDefaultProfileButton.h
//  victorious
//
//  Created by Will Long on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VDefaultProfileImageView.h"

/**
 *  A UIButton for profiles.  It will default the profile image to the themed profile image.
 */
@interface VDefaultProfileButton : UIButton

@property (nonatomic, strong) VDefaultProfileImageView *profileImageView;

- (void)setup;
- (void)setProfileImageURL:(NSURL *)url forState:(UIControlState)controlState;

@end
