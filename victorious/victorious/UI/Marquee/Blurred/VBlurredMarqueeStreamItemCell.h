//
//  VBlurredMarqueeStreamItemCell.h
//  victorious
//
//  Created by Sharif Ahmed on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractMarqueeStreamItemCell.h"

@class VStreamItemPreviewView;

/**
    A cell representing a single stream item in the blurred marquee.
 */
@interface VBlurredMarqueeStreamItemCell : VAbstractMarqueeStreamItemCell

/**
    Adds the provided preview view inside the cell unless it is already being displayed.
 
    @param previewView The previewView that will be added into the cell if not already being displayed.
 */
- (void)updateToPreviewView:(VStreamItemPreviewView *)previewView;

/**
    The optimal frame for content in this cell given the bounds of the collection view it
        will be present in. Assumes that the provided bounds have already taken the
        content and section insets of the collectionView into consideration.
 
    @param bounds The bounds of the collection view that will contain this cell minus the appropriate
        section or content edge insets.
    
    @return The optimal frame for content in this cell.
 */
+ (CGRect)frameForPreviewViewInCellWithBounds:(CGRect)bounds;

@end
