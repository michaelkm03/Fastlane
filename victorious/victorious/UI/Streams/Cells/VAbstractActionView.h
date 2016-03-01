//
//  VAbstractActionView.h
//  victorious
//
//  Created by Michael Sena on 4/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VStreamCellSpecialization.h"
#import "VSequenceActionsDelegate.h"

@class VFlexBar;
@class VSequence;

/**
 *  VAbstractActionView provides a commmon interface for views that use a horizontal
 *  list of action buttons for interactivity with a particlar sequence.
 */
@interface VAbstractActionView : UIView <VStreamCellComponentSpecialization>

/**
 *  A sequence for this action view.
 */
@property (nonatomic, strong) VSequence *sequence;

/**
 *  A delegate to dispatch actions messages to.
 */
@property (nonatomic, weak) id <VSequenceActionsDelegate> sequenceActionsDelegate;

@end

/**
 *  Call these methods from within subclasses to dispatch the approrpiate sequenceActionDelegate
 *  method. Theses are garuanteed to check delegate implementaiton for optional methods.
 */
@interface VAbstractActionView (VActionMethods)

/**
 *  Dispatch the sequence comment message to the current sequence actions delegate.
 */
- (void)comment:(id)sender;

/**
 *  Dispatch the sequence share message to the current sequence actions delegate.
 */
- (void)share:(id)sender;

/**
 *  Dispatch the sequence repost message to the current sequence actions delegate.
 */
- (void)repost:(id)sender;

/**
 *  Dispatch the sequence like message to the current sequence actions delegate.
 */
- (void)like:(id)sender;

/**
 * Dispatch the sequence more message to the current sequence actions delegate.
 */
- (void)more:(id)sender;

@end

/**
 *  Methods in this category should be subclassed for the action view to update the
 *  current state of its buttons.
 */
@interface VAbstractActionView (VUpdateHooks)

/**
 *  Subclasses should install buttons on actionBar configured appropriately for the sequence.
 */
- (void)updateActionItemsOnBar:(VFlexBar *)actionBar
                   forSequence:(VSequence *)sequence;

@end
