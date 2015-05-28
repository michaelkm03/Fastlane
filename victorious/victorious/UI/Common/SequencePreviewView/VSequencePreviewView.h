//
//  VSequencePreviewView.h
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamItemPreviewView.h"

@class VSequence;

/**
 *  VSequencePreviewView is a class cluster for previewing a sequence. A concrete subclass is provided
 *  from the "sequencePreviewViewWithSequence" constructor method. VSequencePreviewView conforms to
 *  VStreamCellComponentSpecialization and should be reused for sequences that return the same reuse
 *  identifier from: "reuseIdentifierForSequence:baseIdentifier:".
 */
@interface VSequencePreviewView : VStreamItemPreviewView

#warning DOCS
+ (Class)classTypeForSequence:(VSequence *)sequence;

+ (NSString *)reuseIdentifierForSequence:(VSequence *)sequence baseIdentifier:(NSString *)baseIdentifier;

/**
 *  The factory method for the VSequencePreviewView, will provide a concrete subclass specialized to
 *  the given sequence.
 */
+ (VSequencePreviewView *)sequencePreviewViewWithSequence:(VSequence *)sequence;

/**
 *  Use to update a sequence preview view for a new sequence.
 */
- (void)setSequence:(VSequence *)sequence;

/**
 *  Returns YES if this instance of VSequencePreviewView can handle the given seuqence.
 */
- (BOOL)canHandleSequence:(VSequence *)sequence;

@end
