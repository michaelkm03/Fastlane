//
//  VLoadingViewController.h
//  victorious
//
//  Created by Will Long on 2/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VLoadingViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIImageView        *backgroundImageView;
@property (nonatomic, weak) IBOutlet UILabel            *reachabilityLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *reachabilityLabelPositionConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *reachabilityLabelHeightConstraint;

@end
