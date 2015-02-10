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

/**
 Designed to be implemented by the view controller of the collection view
 that contains this VContentCell.  The delegate will handle actions and state
 changes performed in the VEndCardViewController.
 */
@property (nonatomic, weak) id<VEndCardViewControllerDelegate> endCardDelegate;

/**
 Used to determine how to fade in or out with an interactive-style animation
 as the cell size is changed.
 */
@property (nonatomic, assign, readwrite) CGSize maxSize;

/**
 Used to determine how to fade in or out with an interactive-style animation
 as the cell size is changed.
 */
@property (nonatomic, assign, readwrite) CGSize minSize;

/**
 Returns @YES if a VEndCardViewController instance has been created and
 added as a subview.
 */
@property (nonatomic, assign, readonly) BOOL isEndCardShowing;

- (void)playAnimation;

/**
 Stops the endcard's countdown timer, if the end card is showing
 */
- (void)disableEndcardAutoplay;

/**
 Creates a new VEndCardViewController instances and adds it as a child
 above the video content, then plays the transition in animations.
 */
- (void)showEndCardWithViewModel:(VEndCardModel *)model;

/**
 Hides the end card by removing it from the view hiearchy.
 */
- (void)hideEndCard;

/**
 Properly rotates itself and subcomponents based on the rotation of the collection view.
 Make sure to forward this from your collection view controller.
 */
- (void)handleRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

@property (nonatomic, strong) UIView *shrinkingContentView;

@end
