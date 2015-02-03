//
//  VContentCell.h
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"
#import "VEndCardViewController.h"

@interface VContentCell : VBaseCollectionViewCell

/**
 *  An array of UIImages to use for the animation.
 */
@property (nonatomic, strong) NSArray *animationSequence;

@property (nonatomic, assign) NSTimeInterval animationDuration;

/**
 *  Defaults to 1.
 */
@property (nonatomic, assign) NSInteger repeatCount;

@property (nonatomic, weak) id<VEndCardViewControllerDelegate> endCardDelegate;

@property (nonatomic, strong, readonly) VEndCardViewController *endCardViewController;

@property (nonatomic, assign, readwrite) CGSize maxSize;

@property (nonatomic, assign, readwrite) CGSize minSize;

@property (nonatomic, assign, readonly) BOOL isEndCardShowing;

- (void)playAnimation;

- (void)showEndCardWithViewModel:(VEndCardModel *)model;

- (void)resetEndCardActions:(BOOL)animated;

/**
 Properly rotates itself and subcomponents based on the rotation of the collection view.
 Make sure to forward this from your collection view controller.
 */
- (void)handleRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

@end
