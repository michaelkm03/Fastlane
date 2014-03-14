//
//  VContentViewController.h
//  victorious
//
//  Created by Will Long on 2/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VAnimation.h"

@class VSequence, VEmotiveBallisticsBarViewController;

extern CGFloat kContentMediaViewOffset;

@interface VContentViewController : UIViewController

@property (strong, nonatomic) VSequence* sequence;
@property (weak, nonatomic) IBOutlet UIView* mediaView;
@property (weak, nonatomic) IBOutlet UIView* topActionsView;
@property (weak, nonatomic) IBOutlet UIImageView* orImageView;
@property (strong, nonatomic) UIViewController<VAnimation>* actionBarVC;

+ (VContentViewController *)sharedInstance;

@end
