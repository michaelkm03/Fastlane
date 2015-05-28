//
//  VStreamPreviewView.h
//  victorious
//
//  Created by Sharif Ahmed on 5/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamItemPreviewView.h"

@class VStream;

@interface VStreamPreviewView : VStreamItemPreviewView

/**
 *  Returns a stream preview view class for the provided stream.
 */
+ (Class)classTypeForStream:(VStream *)stream;

/**
 *  Returns a stream preview view class for the provided stream and base identifier.
 */
+ (NSString *)reuseIdentifierForStream:(VStream *)stream baseIdentifier:(NSString *)baseIdentifier;

/**
 *  The factory method for the VSequencePreviewView, will provide a concrete subclass specialized to
 *  the given sequence.
 */
+ (VStreamPreviewView *)streamPreviewViewWithStream:(VStream *)stream;

/**
 *  Use to update a sequence preview view for a new sequence.
 */
@property (nonatomic, strong) VStream *stream;

/**
 *  Returns YES if this instance of VSequencePreviewView can handle the given seuqence.
 */
- (BOOL)canHandleStream:(VStream *)stream;

@end
