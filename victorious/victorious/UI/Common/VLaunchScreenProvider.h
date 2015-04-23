//
//  VLaunchScreenProvider.h
//  victorious
//
//  Created by Sharif Ahmed on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VLaunchScreenProvider : NSObject

/*
    Adds the view from the launch screen as a subview of the provided view and adds fitting constraints
 
    @param view The view that should have the launch screen view added as a subview
 */
+ (void)addLaunchScreenToView:(UIView *)view;

/*
 Creates a screenshot of the launch screen with the provided size dimensions
 
 @param size The desired size of the launch screen image
 
 @return A screenshot of the launch image at the provided size
 */
+ (UIImage *)screenshotOfLaunchScreenAtSize:(CGSize)size;

@end
