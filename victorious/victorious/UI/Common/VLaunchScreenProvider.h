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
 Initializes the launch screen from the nib and returns the view inside
 
 @return The view from the launch screen
 */
+ (UIView *)launchScreen;

/*
 Creates a screenshot of the launch screen with the provided size dimensions
 
 @param size The desired size of the launch screen image
 
 @return A screenshot of the launch image at the provided size
 */
+ (UIImage *)screenshotOfLaunchScreenAtSize:(CGSize)size;

@end
