//
//  VEndCardActionCell.h
//  AutoplayNext
//
//  Created by Patrick Lynch on 1/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VEndCardActionModel.h"

/**
 A collection view cell shown in the end card that offers users a way to
 perform actions using the current sequence, such as share, respost, etc.
 */
@interface VEndCardActionCell : UICollectionViewCell

@property (nonatomic, assign) BOOL enabled;

/**
 An assignable string identifier that can be used in calling code to know which
 action cell was selected, i.e. which action should be performed when tapped.
 */
@property (nonatomic, readonly) NSString *actionIdentifier;

/**
 To be used by the collection view.
 */
+ (NSString *)cellIdentifier;

/**
 To be used by the collection view layout.
 */
+ (CGSize)minimumSize;

/**
 Uses properties from the `model` parameter to configured to cell.  The
 cell will be empty (no title or image) until this is called with valid
 values assigned to propertes of `VEndCardActionModel`.
 */
- (void)setModel:(VEndCardActionModel *)model;

/**
 Sets the title label font.
 */
- (void)setFont:(UIFont *)font;

/**
 Used for fade in/out the title label when layout is adjusted and cells
 must appear more compact.
 */
- (void)setTitleAlpha:(CGFloat)alpha;

/**
 Set the title and icon image to the success state values supplied by the
 `VEndCardActionModel` instance set with `setModel:` method.
 */
- (void)showSuccessState;

/**
 Set the title and icon image to the default state values supplied by the
 `VEndCardActionModel` instance set with `setModel:` method.
 */
- (void)showDefaultState;

/**
 Play the transition in animation, intended for when the collection view
 first appears.
 */
- (void)transitionInWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;

/**
 Play the transition out animation, intended for just before the collection
 view disappears.  Removal from the view hierarchy and/or deallocation
 should be held off until animation is completed and triggered in the completion block.
 */
- (void)transitionOutWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void(^)(BOOL finished))completion;

@end
