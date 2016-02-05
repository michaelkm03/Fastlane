//
//  VSequencePreviewView.h
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamItemPreviewView.h"
#import "VContentLikeButton.h"
#import "VFocusable.h"
#import "VSequencePreviewViewProtocols.h"

@class VSequence, VTracking;

/**
 *  VSequencePreviewView is a class cluster for previewing a sequence. A concrete subclass is provided
 *  from the "sequencePreviewViewWithSequence" constructor method. VSequencePreviewView conforms to
 *  VStreamCellComponentSpecialization and should be reused for sequences that return the same reuse
 *  identifier from: "reuseIdentifierForSequence:baseIdentifier:".
 */
@interface VSequencePreviewView : VStreamItemPreviewView <VFocusable>

/**
 *  Returns a sequence preview view class for the provided sequence.
 */
+ (Class)classTypeForSequence:(VSequence *)sequence;

/**
 *  Returns an appropriate reuse identifier for the provided sequence and base identifier.
 */
+ (NSString *)reuseIdentifierForSequence:(VSequence *)sequence baseIdentifier:(NSString *)baseIdentifier dependencyManager:(VDependencyManager *)dependencyManager;

/**
 *  The factory method for the VSequencePreviewView, will provide a concrete subclass specialized to
 *  the given sequence.
 */
+ (VSequencePreviewView *)sequencePreviewViewWithSequence:(VSequence *)sequence;

@property (nonatomic, strong) VSequence *sequence;

@property (nonatomic, weak) id<VSequencePreviewViewDetailDelegate> detailDelegate;

/**
 This likeButton is hidden by default.
 Call showLikeButton:shouldShowLikeButton to configure and show it
 */
@property (nonatomic, strong, readonly) VContentLikeButton *likeButton;

/**
 Call this method to show or hide the like button on this preview view
 The like button will only show up if it is enabled in template
 */
- (void)showLikeButton:(BOOL)shouldShowLikeButton;

/**
 *  Returns YES if this instance of VSequencePreviewView can handle the given sequence.
 */
- (BOOL)canHandleSequence:(VSequence *)sequence;

- (void)setGesturesEnabled:(BOOL)enabled;

- (void)updateBackgroundColorAnimated:(BOOL)animated;

/**
 Contains tracking data necessary any of the lifecycle or interation events that occur
 during the lifetime of this instance.  Tracking ultimate comes from VStreamItemPointer objects,
 so this property must be set from the stream which the sequence came.
 */
@property (nonatomic, strong) VTracking *trackingData;

@end
