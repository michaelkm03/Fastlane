//
//  VLaunchScreenProvider.m
//  victorious
//
//  Created by Sharif Ahmed on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLaunchScreenProvider.h"
#import "UIView+AutoLayout.h"

@implementation VLaunchScreenProvider

+ (void)addLaunchScreenToView:(UIView *)view
{
    NSAssert(view != nil, @"View that should recieve launch screen passed to addLaunchScreenToView: should not be nil");
    UIView *launchScreenView = [self launchScreen];
    launchScreenView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:launchScreenView];
    [view v_addFitToParentConstraintsToSubview:launchScreenView];
}

+ (UIImage *)screenshotOfLaunchScreenAtSize:(CGSize)size
{
    UIView *launchScreenView = [self launchScreen];
    CGRect newBounds = launchScreenView.bounds;
    newBounds.size = size;
    launchScreenView.bounds = newBounds;
    UIGraphicsBeginImageContext(launchScreenView.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [launchScreenView.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIView *)launchScreen
{
    NSAssert([NSThread isMainThread], @"functions in VLaunchScreenProvider must be called on the main thread");
    UINib *launchScreenNib = [UINib nibWithNibName:@"Launch Screen" bundle:nil];
    return [[launchScreenNib instantiateWithOwner:nil options:nil] firstObject];
}

@end
