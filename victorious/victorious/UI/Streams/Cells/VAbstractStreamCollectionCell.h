//
//  VAbstractStreamCollectionCell.h
//  victorious
//
//  Created by Michael Sena on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

// Protocols
#import "VBackgroundContainer.h"
#import "VHasManagedDependencies.h"
#import "VSequenceActionsSender.h"

@class VSequence;

@interface VAbstractStreamCollectionCell : VBaseCollectionViewCell <VBackgroundContainer, VHasManagedDependencies, VSequenceActionsSender>

/**
 *  The sequence this stream collection cell represents. Subclasses may override
 *  "-setSequence:" but they MUST call super in their implementation.
 */
@property (nonatomic, strong) VSequence *sequence;

/**
 *  The previewView contains a preview for the given sequence. A pollView for 
 *  a poll, an imageView for an image, etc.
 *
 *  Subclasses should add this view to their view hierarchy where appropriate. 
 *  It will exist after any init family method returns.
 */
@property (nonatomic, strong, readonly) UIView *previewView;

/**
 *  For subclasses to reference. Subclasses may override VHasManagedDependencies'
 *  "-setDependencyManager:", but you MUST call super.
 */
@property (nonatomic, strong, readonly) VDependencyManager *dependencyManager;

/**
 *  Return an identifier that will minimize the amount of view hierarchy setup
 *  and layout calculations that need to occur when a new cell comes on screen.
 *
 *  For example an image post and poll post should be separate identifiers so
 *  that the content view (imageView or pollView) will only have to undergo
 *  setup/layout once.
 *
 *  Abstract method. Should be overriden by concrete subclasses.
 */
+ (NSString *)reuseIdentifierForSequence:(VSequence *)sequence;

/**
 *  Convenience method for subclasses to determine whether or not they should 
 *  overlay UI on top of the previewView.
 */
+ (BOOL)canOverlayContentForSequence:(VSequence *)sequence;

@end

@interface VAbstractStreamCollectionCell (Sizing)

/**
 *  Override this method in subclasses to provide callers a custom sizing. 
 *  Default method will return a size of CGSizeMake(bounds.width,bounds.width).
 */
+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds
                                    sequence:(VSequence *)sequence
                           dependencyManager:(VDependencyManager *)dependencyManager;

@end

/**
 *  These methods provide convenience checks to ensure the delegate responds to 
 *  the appropriate delegate methods.
 */
@interface VAbstractStreamCollectionCell (Actions)

/**
 *  Base implementation checks conformance on sequenceActionsDelegate for the approrpiate 
 *  delegate method and sends that message.
 *
 *  @param hashTag the hash tag selected from this cell.
 */
- (void)selectedHashTag:(NSString *)hashTag;


/**
 *  Base implementation checks conformance on sequenceActionsDelegate for the approrpiate
 *  delegate method and sends that message.
 */
- (void)comment;

@end

/**
 *  Override these methods to update UI where appropriate. VAbstractStreamCollectionCell 
 *  will observe the appropriate models to provide subclasses an opportunity to update 
 *  themselves. External classes may call these methods using the sequence property of
 *  the VAbstractStreamCollectionCell for the sequence parameter.
 *
 *  Base implementations do nothing.
 */
@interface VAbstractStreamCollectionCell (UpdateHooks)

/**
 *  Subclasses should override this method to update comment counts for this sequence.
 */
- (void)updateCommentsForSequence:(VSequence *)sequence;

/**
 *  Subclass should override this method to update the username for the author of this 
 *  sequence.
 */
- (void)updateUsernameForSequence:(VSequence *)sequence;

/**
 *  Subclasses should override this method ot update an avatar imageView for the author
 *  of this sequence.
 */
- (void)updateUserAvatarForSequence:(VSequence *)sequence;

@end