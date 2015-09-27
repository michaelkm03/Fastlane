//
//  VImageStreamPreviewView.h
//  victorious
//
//  Created by Sharif Ahmed on 5/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamPreviewView.h"
#import "VImagePreviewView.h"

@interface VImageStreamPreviewView : VStreamPreviewView <VImagePreviewView>

/**
 The image view that displays the sequence preview image.
 */
@property (nonatomic, readonly) UIImageView *previewImageView;

@end
