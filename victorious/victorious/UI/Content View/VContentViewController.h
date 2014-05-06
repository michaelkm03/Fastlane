//
//  VContentViewController.h
//  victorious
//
//  Created by Will Long on 2/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VAnimation.h"

@class VSequence, VEmotiveBallisticsBarViewController, VActionBarViewController;

extern CGFloat kContentMediaViewOffset;

@interface VContentViewController : UIViewController <VAnimation>

@property (strong, nonatomic) VSequence* sequence;
@property (strong, nonatomic) VActionBarViewController* actionBarVC;

@property (weak, nonatomic) IBOutlet UIView* pollPreviewView;
@property (weak, nonatomic) IBOutlet UIView* orContainerView;
@property (weak, nonatomic) IBOutlet UIView* mediaView;
@property (weak, nonatomic) IBOutlet UIView* topActionsView;

@property (weak, nonatomic) IBOutlet UIImageView* orImageView;
@property (weak, nonatomic) IBOutlet UIImageView* previewImage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint* previewImageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* previewImageHeightConstraint;

@property (weak, nonatomic) IBOutlet UIButton* firstPollButton;
@property (weak, nonatomic) IBOutlet UIButton* secondPollButton;

+ (VContentViewController *)sharedInstance;

@end
