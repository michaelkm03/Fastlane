//
//  VEndCardActionCell.h
//  AutoplayNext
//
//  Created by Patrick Lynch on 1/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VEndCardActionCell : UICollectionViewCell

+ (NSString *)cellIdentifier;

+ (CGSize)minimumSize;

- (void)setTitle:(NSString *)title;

- (void)setImage:(UIImage *)image;

- (void)setTitleAlpha:(CGFloat)alpha;

/**
 Aniamtes into a disabled state.
 */
- (void)playDisableAnimation;

/**
 Return to the initial starting state without animation
 */
- (void)resetSelectionStateAnimated:(BOOL)animated;

- (void)transitionInWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;

- (void)transitionOutWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void(^)(BOOL finished))completion;

@end
