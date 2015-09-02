//
//  VImageViewContainer.h
//  victorious
//
//  Created by Sharif Ahmed on 4/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    A simple container for a single image view. Just adds autolayout constraints to an image view
        such that the image view always fits the bounds of this view
 */
@interface VImageViewContainer : UIView

@property (nonatomic, strong) UIImageView *imageView;

@end
