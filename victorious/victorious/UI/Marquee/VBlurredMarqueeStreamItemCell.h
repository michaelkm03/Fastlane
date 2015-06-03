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
    Adds the provided preview view inside the cell unless it is already being displayed.
 
    @param previewView The previewView that will be added into the cell if not already being displayed.
 */
- (void)updateToPreviewView:(VStreamItemPreviewView *)previewView;

+ (CGRect)frameForPreviewViewInCellWithBounds:(CGRect)bounds;

@end
