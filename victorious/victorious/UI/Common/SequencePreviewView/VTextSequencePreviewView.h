//
//  VTextSequencePreviewView.h
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSequencePreviewView.h"

/**
 A preview view for displaying a text asset on a sequence.
 */
@interface VTextSequencePreviewView : VSequencePreviewView

/**
 Creates an image from this text sequence preview view. Will render at
 the displaySize if it's set.
 */
- (void)renderTextPostPreviewImageWithCompletion:(void(^)(UIImage *image))completion;

@end
