//
//  VSideMenuViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VScaffoldViewController.h"

#import <UIKit/UIKit.h>

@class VNavigationController;

@interface VSideMenuViewController : VScaffoldViewController

@property (assign, readwrite, nonatomic) NSTimeInterval animationDuration;
@property (strong, readwrite, nonatomic) UIImage *backgroundImage;
@property (assign, readwrite, nonatomic) BOOL scaleContentView;
@property (assign, readwrite, nonatomic) BOOL scaleBackgroundImageView;
@property (assign, readwrite, nonatomic) CGFloat contentViewScaleValue;
@property (assign, readwrite, nonatomic) CGFloat contentViewInLandscapeOffsetCenterX;
@property (assign, readwrite, nonatomic) CGFloat contentViewInPortraitOffsetCenterX;
@property (strong, readwrite, nonatomic) id parallaxMenuMinimumRelativeValue;
@property (strong, readwrite, nonatomic) id parallaxMenuMaximumRelativeValue;
@property (strong, readwrite, nonatomic) id parallaxContentMinimumRelativeValue;
@property (strong, readwrite, nonatomic) id parallaxContentMaximumRelativeValue;
@property (assign, readwrite, nonatomic) BOOL parallaxEnabled;
@property (assign, readwrite, nonatomic) BOOL bouncesHorizontally;

@property (strong, readonly, nonatomic)  VNavigationController *contentViewController;

- (void)presentMenuViewController;
- (void)hideMenuViewController;

@end
