//
//  VHistogramCell.h
//  victorious
//
//  Created by Michael Sena on 10/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@class VHistogramCell;

@protocol VHistogramDataSource <NSObject>

- (CGFloat)valueForTickerSliceIndex:(NSInteger)sliceIndex
                        totalSlices:(NSInteger)totalSlices;

@end

@interface VHistogramCell : VBaseCollectionViewCell

/**
 *  This value must be between 0 and 1 (inclusive).
 */
@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, weak) id <VHistogramDataSource> dataSource;

@end
