//
//  VPhotoFilterCollectionViewDataSource.h
//  victorious
//
//  Created by Josh Hinman on 7/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VPhotoFilter;

extern NSString * const kPhotoFilterCellIdentifier;
extern const NSInteger kVOriginalImageSectionIndex; ///< A collection view section index with one item: the original photo (no filter)
extern const NSInteger kVPhotoFiltersSectionIndex;  ///< The collection view section containing all the photo filters

@interface VPhotoFilterCollectionViewDataSource : NSObject <UICollectionViewDataSource>

/**
 The preview image in each photo filter cell
 will be a filtered version of this image.
 */
@property (nonatomic, strong) UIImage *sourceImage;

/**
 Returns the filter that corresponds to the cell at the given index path.
 */
- (VPhotoFilter *)filterAtIndexPath:(NSIndexPath *)indexPath;

@end
