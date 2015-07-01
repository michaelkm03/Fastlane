//
//  VStreamPreviewView.h
//  victorious
//
//  Created by Sharif Ahmed on 5/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamItemPreviewView.h"

@class VStream;

/**
 *  VStreamPreviewView is a class cluster for previewing a sequence. A concrete subclass is provided
 *  from the "streamPreviewViewWithStream:" constructor method. VStreamPreviewView conforms to
 *  VStreamCellComponentSpecialization and should be reused for sequences that return the same reuse
 *  identifier from: "reuseIdentifierForSequence:baseIdentifier:".
 */
@interface VStreamPreviewView : VStreamItemPreviewView

/**
 *  Returns a stream preview view class for the provided stream.
 */
+ (Class)classTypeForStream:(VStream *)stream;

/**
 *  Returns a stream preview view class for the provided stream and base identifier.
 */
+ (NSString *)reuseIdentifierForStream:(VStream *)stream baseIdentifier:(NSString *)baseIdentifier dependencyManager:(VDependencyManager *)dependencyManager;

/**
 *  The factory method for the VStreamPreviewView, will provide a concrete subclass specialized to
 *  the given stream.
 */
+ (VStreamPreviewView *)streamPreviewViewWithStream:(VStream *)stream;

/**
 *  Use to update a stream preview view for a new stream.
 */
- (void)setStream:(VStream *)stream;

/**
 *  Returns YES if this instance of VStreamPreviewView can handle the given stream.
 */
- (BOOL)canHandleStream:(VStream *)stream;

@end
