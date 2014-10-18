//
//  VHistogramView.h
//  victorious
//
//  Created by Michael Sena on 10/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VHistogramBarView;

@protocol VHistogramBarViewDataSource <NSObject>

- (CGFloat)histogramPercentageHeight:(VHistogramBarView *)histogramView
                         forBarIndex:(NSInteger)barIndex
                           totalBars:(NSInteger)totalBars;

@end

/**
 *  VHistogramBarView draws a histogram as a series of bars. Each bar has a fixed width and a fixed spacing between other bars. The histogramBarView also has a notion of progress, setting the progress property will change the coloring of the individual bars to reflect the progress of the timeline this histogram is representing.
 */
@interface VHistogramBarView : UIView

/**
 *  This value must be between 0 and 1 (inclusive).
 */
@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, weak) id <VHistogramBarViewDataSource> dataSource;

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

@end
