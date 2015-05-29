//
//  VTabBarViewController.h
//  victorious
//
//  Created by Josh Hinman on 6/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Kinda like UITabBarController, except 
 the tab bar buttons are on top.
 */
@interface VTabBarViewController : UIViewController

@property (nonatomic, strong) UIColor *buttonBackgroundColor;
@property (nonatomic, strong) NSArray /* VTabInfo */ *viewControllers;

@end
