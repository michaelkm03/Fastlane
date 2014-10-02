//
//  VDefaultProfileImageView.h
//  victorious
//
//  Created by Will Long on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VUser;

/**
 *  An image view that defaults to the themed default profile image.
 */
@interface VDefaultProfileImageView : UIImageView

@property (nonatomic, strong) VUser *user; ///<Updating this property updates the URL used for the profile Image.

@end
