//
//  VHistogramView.h
//  victorious
//
//  Created by Michael Sena on 10/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VHistogramView;

@protocol VHistogramDataSource <NSObject>

- (CGFloat)histogram:(VHistogramView *)histogramView
 heightForSliceIndex:(NSInteger)sliceIndex
         totalSlices:(NSInteger)totalSlices;

@end

@interface VHistogramView : UIView

/**
 *  This value must be between 0 and 1 (inclusive).
 */
@property (nonatomic, assign) CGFloat progress;


@property (nonatomic, weak) id <VHistogramDataSource> dataSource;

/**
 *  Each slice of the histogram is the same width. So this is derived by the space given to the view.
 */
@property (nonatomic, readonly) NSInteger totalSlices;

/**
 *  In points. Defaults to 2.
 */
@property (nonatomic, assign) CGFloat tickWidth;

/**
 *  In points. Defaults to 1.
 */
@property (nonatomic, assign) CGFloat tickSpacing;

/**
 *  Prompts a query of the data source.
 */
- (void)reloadData;

@end
