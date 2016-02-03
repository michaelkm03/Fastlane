//
//  VNoContentView.h
//  victorious
//
//  Created by Will Long on 6/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"

@interface VNoContentView : UIView <VHasManagedDependencies>

/**
 *  Use this factory method to create VNoContentViews.
 */
+ (instancetype)viewFromNibWithFrame:(CGRect)frame;

/**
 *  The title to display to inform the user of no content.
 */
@property (nonatomic, strong) NSString *title;

/**
 *  The message to display to inform the user why there is no content.
 */
@property (nonatomic, strong) NSString *message;

/**
 *  An icon to display about the missing content.
 */
@property (nonatomic, strong) UIImage *icon;

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds titleString:(NSString *)titleString messageString:(NSString *)messageString andDependencyManager:(VDependencyManager *)dependencyManager;

/**
 Resets animation state to prepare for a call to `animateTransitionIn`.
 */
- (void)resetInitialAnimationState;

/**
 Animates the no content view's message and icon UI using a springy
 scale-up and fade-in animation.
 */
- (void)animateTransitionIn;

@end