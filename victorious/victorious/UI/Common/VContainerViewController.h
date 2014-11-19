//
//  VContainerViewController.h
//  victorious
//
//  Created by Will Long on 10/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A View Controller designed to contain a static table view and provide the themed header.
 Very naive implementation that assumes there is one and only one child VC in it.
 */
@interface VContainerViewController : UIViewController

@property (nonatomic, weak) UIViewController *containedViewController; ///< The view controller that is contained.
@property (nonatomic, weak) IBOutlet UIView *containerView; ///< The view that contains the child VC

@end
