//
//  VLoadingViewController.h
//  victorious
//
//  Created by Will Long on 2/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const VLoadingViewControllerLoadingCompletedNotification; ///< Posted when the init server call returns successfully

@interface VLoadingViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIImageView        *backgroundImageView;
@property (nonatomic, weak) IBOutlet UILabel            *reachabilityLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *reachabilityLabelPositionConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *reachabilityLabelHeightConstraint;

+ (VLoadingViewController *)loadingViewController; ///< Instantiates VLoadingViewController from the storyboard

@end
