//
//  VDirectoryCollectionFlowLayout.h
//  victorious
//
//  Created by Sharif Ahmed on 4/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VDirectoryCollectionFlowLayoutDelegate <NSObject>

@required
- (BOOL)hasMarqueeCell;

@end

/**
    A collectionViewFlowLayout with helper functions to allow subclasses to realize if it is returning layout attributes for a marquee cell
 */
@interface VDirectoryCollectionFlowLayout : UICollectionViewFlowLayout

/**
    Returns whether or not the provided index path is describing a marquee cell. Should be utilized by subclasses to
        return custom layout attributes for a marquee cell
 
    @param indexPath The index path where a marquee cell might be presented
 
    @return YES if the index path could be a valid index path for a marquee cell and our delegate returns YES for hasHeaderCell
 */
- (BOOL)isMarqueeCellAtIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, weak) id <VDirectoryCollectionFlowLayoutDelegate> delegate;

@end
