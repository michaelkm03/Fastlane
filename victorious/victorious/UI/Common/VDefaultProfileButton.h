//
//  VDefaultProfileButton.h
//  victorious
//
//  Created by Will Long on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VDefaultProfileImageView.h"

@class VUser;

/**
 *  A UIButton for profiles.  It will default the profile image to the themed profile image.
 */
@interface VDefaultProfileButton : UIButton

@property (nonatomic, strong) VDefaultProfileImageView *profileImageView;///< A VDefaultProfileImageView that is used instead of the normal imageView.  Note: if you use set or use the default image view, you may get unexpected behavior.
@property (nonatomic, strong) VUser *user;///<Setting this property updates the URL of the profileImageView

@end
