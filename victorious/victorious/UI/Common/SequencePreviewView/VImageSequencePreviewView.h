//
//  VImageSequencePreviewView.h
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSequencePreviewView.h"
#import "VImagePreviewView.h"
#import "VFocusable.h"
#import "VContentFittingPreviewView.h"

@interface VImageSequencePreviewView : VSequencePreviewView <VImagePreviewView, VFocusable, VContentFittingPreviewView>

/**
 The image view that displays the sequence preview image.
 */
@property (nonatomic, readonly) UIImageView *previewImageView;

@end
