//
//  VDirectoryGroupCell.h
//  victorious
//
//  Created by Sharif Ahmed on 2/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"
#import "VDependencyManager.h"

extern const NSUInteger VDirectoryMaxItemsPerGroup;

@class VStreamItem, VDirectoryGroupCell, VStream, VSequence;

extern CGFloat const kStreamDirectoryGroupCellInset;

@protocol VDirectoryGroupCellDelegate <NSObject>

- (void)streamDirectoryGroupCell:(VDirectoryGroupCell *)groupCell didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface VDirectoryGroupCell : VBaseCollectionViewCell

/**
 *  The desired height for a directory item cell that has space for a stack-style extension at the bottom.
 */
+ (CGFloat)desiredStreamOfStreamsHeightForWidth:(CGFloat)width;

/**
 *  The desired height for a directory item cell that is just a stream of content.
 */
+ (CGFloat)desiredStreamOfContentHeightForWidth:(CGFloat)width;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
 *  The VStreamItem used to populate fields on the cell.
 */
@property (nonatomic, strong) VStreamItem *streamItem;

/**
    The item cell delegate that will respond to selections made within the collectionView contained in this cell
 */
@property (nonatomic, weak) id <VDirectoryGroupCellDelegate> delegate;

/**
 A convenient flag for checking if this row is of stream of stream cells or just a row of stream cells
 */
@property (nonatomic, readonly) BOOL isStreamOfStreamsRow;

@property (nonatomic, weak, readonly) VStream *stream;

@property (nonatomic, weak, readonly) VSequence *sequence;

@end
