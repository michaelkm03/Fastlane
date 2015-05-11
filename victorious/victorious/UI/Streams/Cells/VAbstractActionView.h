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

@class VActionBar;
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

/**
 *  While this is true we are waiting on the network to repost this sequence.
 *  Override this setter to enable/disable controls where appropriate.
 */
@property (nonatomic, assign) BOOL reposting;

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
 *  Dispatch the sequence meme message to the current sequence actions delegate.
 */
- (void)meme:(id)sender;

/**
 *  Dispatch the sequence gif message to the current sequence actions delegate.
 */
- (void)gif:(id)sender;

@end

/**
 *  Methods in this category should be subclassed for the action view to update the 
 *  current state of its buttons.
 */
@interface VAbstractActionView (VUpdateHooks)

/**
 *  Subclasses should install buttons on actionBar configured appropriately for the sequence.
 */
- (void)updateActionItemsOnBar:(VActionBar *)actionBar
                   forSequence:(VSequence *)sequence;

/**
 *  Subclasses should update any comment count UI they have here.
 */
- (void)updateCommentCountForSequence:(VSequence *)sequence;

/**
 *  Subclasses should update any repost buttons for the passed in sequence.
 */
- (void)updateRepostButtonForSequence:(VSequence *)sequence;

@end
