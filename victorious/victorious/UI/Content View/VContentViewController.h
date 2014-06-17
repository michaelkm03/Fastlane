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

@interface VContentViewController : UIViewController <VAnimation>

@property (strong, nonatomic) VSequence* sequence;
@property (strong, nonatomic) VActionBarViewController* actionBarVC;

@property (weak, nonatomic) IBOutlet UIView* pollPreviewView;
@property (weak, nonatomic) IBOutlet UIView* orContainerView;
@property (weak, nonatomic) IBOutlet UIView* mediaSuperview;
@property (weak, nonatomic) IBOutlet UIView* mediaView;
@property (weak, nonatomic) IBOutlet UIView* topActionsView;

@property (weak, nonatomic) IBOutlet UIImageView* orImageView;
@property (weak, nonatomic) IBOutlet UIImageView* previewImage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint* leftSmallPreviewImageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* rightSmallPreviewImageWidthConstraint;

@property (weak, nonatomic) IBOutlet UIView* firstPollPlayIcon;
@property (weak, nonatomic) IBOutlet UIView* secondPollPlayIcon;

@property (weak, nonatomic) IBOutlet UIButton* firstPollButton;
@property (weak, nonatomic) IBOutlet UIButton* secondPollButton;

@property (strong, nonatomic) UIImage *leftPollThumbnail;
@property (strong, nonatomic) UIImage *rightPollThumbnail;

+ (VContentViewController *)sharedInstance;

/**
 Returns the distance, in points, between
 the top of the receiver's view and the
 top of the media view contained within.
 
 Make sure view has been laid out before
 trusting this method. (try calling 
 -layoutIfNeeded).
 */
- (CGFloat)contentMediaViewOffset;

/**
 Guesses what the result of calling -contentMediaViewOffset
 will probably be with the given bounds.
 */
+ (CGFloat)estimatedContentMediaViewOffsetForBounds:(CGRect)bounds;

@end
