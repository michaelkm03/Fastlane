//
//  VDirectoryPlaylistCell.h
//  victorious
//
//  Created by Sharif Ahmed on 3/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@class VStreamItem, VDependencyManager;

@interface VDirectoryCollectionsCell : VBaseCollectionViewCell

/**
 *  Animates the opacity and size of the cell to or from the "visible" state. A cell in the invisible state is slightly smaller and completely transparent.
 */
- (void)animate:(BOOL)animate toVisible:(BOOL)visible afterDelay:(CGFloat)delay;

/**
 *  The VStream used to populate fields on the cell.
 */
@property (nonatomic, strong) VStreamItem *stream;

/**
 *  A value in the range of [-1,1] that will be used to update the offset of the preview image inside the cell
 */
@property (nonatomic, assign) CGFloat parallaxYOffset;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
