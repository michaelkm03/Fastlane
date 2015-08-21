//
//  VImageSequencePreviewView.h
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSequencePreviewView.h"
#import "VPreviewViewBackgroundHost.h"
#import "VImagePreviewView.h"

@interface VImageSequencePreviewView : VSequencePreviewView <VPreviewViewBackgroundHost, VImagePreviewView>

/**
 The image view that displays the sequence preview image.
 */
@property (nonatomic, readonly) UIImageView *previewImageView;

@end
