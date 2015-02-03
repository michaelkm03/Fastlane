//
//  VEndCardViewController.h
//  AutoplayNext
//
//  Created by Patrick Lynch on 1/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VEndCardAnimator.h"
#import "VEndCardModel.h"
#import "VEndCardActionCell.h"

@class VDependencyManager;

@protocol VEndCardViewControllerDelegate <NSObject>
@required

- (void)replaySelectedFromEndCard:(VEndCardViewController *)endCardViewController;

- (void)nextSelectedFromEndCard:(VEndCardViewController *)endCardViewController;

- (void)actionCell:(VEndCardActionCell *)actionCell selectedWithIndex:(NSUInteger)index;

@end

/**
 A view controller designed to appear after a video has played, providing options
 for further engagement and navigating to the next sequence in a stream
 from which the video came.
 */
@interface VEndCardViewController : UIViewController

@property (nonatomic, weak) id<VEndCardViewControllerDelegate> delegate;

+ (VEndCardViewController *)newWithDependencyManager:(VDependencyManager *)dependencyManager
                                               model:(VEndCardModel *)model
                                       minViewHeight:(CGFloat)minViewHeight
                                       maxViewHeight:(CGFloat)maxViewHeight;

@property (nonatomic, readonly) VEndCardModel *model;

@property (nonatomic, readonly) NSArray *actions;

/**
 Animates all elements into the view.
 */
- (void)transitionIn;

/**
 Animates all elements out of the view.
*/
- (void)transitionOutAllWithBackground:(BOOL)withBackground completion:(void(^)())completion;

- (void)handleRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

@end
