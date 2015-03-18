//
//  VActionSheetViewController.h
//  victorious
//
//  Created by Michael Sena on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VActionItem.h"

/**
 *  The ActionSheetViewController presents a list of VActionItems in a tableView.  ActionsheetViewController has a blurred background and expects to be presented with an instance of VActionSheetViewController as it's transitioning delegate.
 */
@interface VActionSheetViewController : UIViewController

+ (VActionSheetViewController *)actionSheetViewController;

/**
 *  Add these action items to the action sheet viewcontroller. Must be of class VActionItem.
 *
 *  @param actionItems An NSArray of VActionItems.
 */
- (void)addActionItems:(NSArray *)actionItems;

@property (nonatomic, readonly) UIView *avatarView;

@property (nonatomic, readonly) CGFloat totalHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topAlignmentAvatarViewToBlurredContainerConstraint;

/**
 Sets the cell for the supplied item into a loading state.
 */
- (void)setLoading:(BOOL)loading forItem:(VActionItem *)item;

@end
