//
//  VDefaultProfileImageView.h
//  victorious
//
//  Created by Will Long on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  An image view that defaults to the themed default profile image.
 */
@interface VDefaultProfileImageView : UIImageView

/**
 The width of the border. Defaults to 0.
 */
@property (nonatomic, assign) CGFloat borderWidth;

/**
 The color of the border. Defaults to white.
 */
@property (nonatomic, strong) UIColor *borderColor;

- (void)setup;
- (void)setProfileImageURL:(NSURL *)url;

@end
