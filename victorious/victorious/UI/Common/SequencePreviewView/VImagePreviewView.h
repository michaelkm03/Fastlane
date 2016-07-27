//
//  VImagePreviewView.h
//  victorious
//
//  Created by Sharif Ahmed on 8/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

/**
 Describes a preview view that handles an image.
 */
@protocol VImagePreviewView <NSObject>

/**
 The image view that displays the sequence preview image.
 */
- (UIImageView *)previewImageView;

@end
