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

@class VSequence;

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

@property (nonatomic, strong, readonly) VContentLikeButton *likeButton;

/**
 Designed to be overridden by subclasses for any content types for which the like button shouldn't be enabled.
 Returns no by default, i.e. the like button is enabled by default.
 */
@property (nonatomic, assign, readonly) BOOL shouldHideLikeButton;

/**
 *  Returns YES if this instance of VSequencePreviewView can handle the given sequence.
 */
- (BOOL)canHandleSequence:(VSequence *)sequence;

- (void)setGesturesEnabled:(BOOL)enabled;

- (void)updateBackgroundColorAnimated:(BOOL)animated;

- (void)setLikebuttonVisible:(BOOL)visible;

@end
