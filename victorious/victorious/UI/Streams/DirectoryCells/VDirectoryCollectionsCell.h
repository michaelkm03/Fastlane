//
//  VDirectoryPlaylistCell.h
//  victorious
//
//  Created by Sharif Ahmed on 3/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@class VStreamItem;

@interface VDirectoryCollectionsCell : VBaseCollectionViewCell

- (void)animate:(BOOL)animate toVisible:(BOOL)visible afterDelay:(CGFloat)delay;

/**
 *  The VStream used to populate fields on the cell.
 */
@property (nonatomic, strong) VStreamItem *stream;

/**
 *  A value in the range of [-1,1] that will be used to update the offset of the preview image inside the cell
 */
@property (nonatomic, assign) CGFloat parallaxYOffset;

@end
