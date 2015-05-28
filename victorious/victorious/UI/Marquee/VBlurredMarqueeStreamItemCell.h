//
//  VBlurredMarqueeStreamItemCell.h
//  victorious
//
//  Created by Sharif Ahmed on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractMarqueeStreamItemCell.h"

@class VStreamItemPreviewView;

@interface VBlurredMarqueeStreamItemCell : VAbstractMarqueeStreamItemCell

/**
    Sets the image in the previewImageView with or without a fade animation
 
    @param image The image to display
 */
- (void)updateToPreviewView:(VStreamItemPreviewView *)previewView;

+ (CGRect)frameForPreviewViewInCellWithBounds:(CGRect)bounds;

@end
