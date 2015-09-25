//
//  VTextSequencePreviewView.h
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSequencePreviewView.h"

@interface VTextSequencePreviewView : VSequencePreviewView

- (void)renderTextPostPreviewImageWithCompletion:(void(^)(UIImage *image))completion;

@end
