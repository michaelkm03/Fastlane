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

- (NSInteger)numberOfSlicesForHistogramView:(VHistogramView *)histogramView;

- (CGFloat)histogramPercentageHeight:(VHistogramView *)histogramView
                       forSliceIndex:(NSInteger)sliceIndex;

@end

@interface VHistogramView : UIView

/**
 *  This value must be between 0 and 1 (inclusive).
 */
@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, weak) id <VHistogramDataSource> dataSource;

/**
 *  In points. Defaults to 2.
 */
@property (nonatomic, assign) CGFloat tickWidth;

/**
 *  In points.
 */
@property (nonatomic, assign) CGFloat tickSpacing;

/**
 *  Prompts a query of the data source.
 */
- (void)reloadData;

- (NSInteger)numberOfSlices;

- (NSInteger)desiredSlicesWithFrame:(CGRect)frame
                          tickWidth:(CGFloat)tickWidth
                        tickSpacing:(CGFloat)tickSpacing;

@end
