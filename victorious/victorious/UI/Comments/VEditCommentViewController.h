//
//  VEditCommentViewController.h
//  victorious
//
//  Created by Patrick Lynch on 12/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSimpleModalTransition.h"

NS_ASSUME_NONNULL_BEGIN

@class VComment, VDependencyManager;

@interface VCommentTextView : UITextView

@end

@protocol VEditCommentViewControllerDelegate <NSObject>

- (void)didFinishEditingComment:(VComment *)comment;

@end

@interface VEditCommentViewController : UIViewController <VSimpleModalTransitionPresentedViewController>

+ (VEditCommentViewController *)newWithComment:(VComment *)comment dependencyManager:(VDependencyManager *)dependencyManager;

@property (weak, nonatomic) IBOutlet UIView *modalContainer;
@property (weak, nonatomic) IBOutlet UIView *backgroundScreen;
@property (weak, nonatomic) IBOutlet UIButton *buttonConfirm;
@property (weak, nonatomic) IBOutlet UIButton *buttonCancel;

@property (weak, nonatomic) id<VEditCommentViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
