//
//  VHistogramDataSource.m
//  victorious
//
//  Created by Michael Sena on 10/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHistogramDataSource.h"

@interface VHistogramDataSource ()

@property (nonatomic, strong) NSArray *dataPoints;
@property (nonatomic, assign) NSInteger largestPoint;

@end

@implementation VHistogramDataSource

- (instancetype)initWithDataPoints:(NSArray *)dataPoints
{
    self = [super init];
    if (self)
    {
        // Check values
        NSAssert((dataPoints.count > 0), @"Must pass in at lest 1 data point");
        [dataPoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
        {
            NSAssert([obj isKindOfClass:[NSNumber class]], @"Must pass in an array of NSValue wrapped NSIntegers");
            NSNumber *point = (NSNumber *)obj;
            NSAssert(([point integerValue] >= 0), @"Must pass in positive values, passed in: %li", (long)[point integerValue]);
        }];
        
        _dataPoints = dataPoints;
        _largestPoint = [[dataPoints firstObject] integerValue];
        [dataPoints enumerateObjectsUsingBlock:^(NSNumber *dataPoint, NSUInteger idx, BOOL *stop)
        {
            _largestPoint = ([dataPoint integerValue] > _largestPoint) ? [dataPoint integerValue] : _largestPoint;
        }];
    }
    return self;
}

#pragma mark - VHistogramDataSource

- (CGFloat)histogramPercentageHeight:(VHistogramBarView *)histogramView
                         forBarIndex:(NSInteger)barIndex
                           totalBars:(NSInteger)totalBars
{
    NSNumber *dataPointForBarIndex = [self dataPointForBarIndex:barIndex
                                                  WithTotalBars:totalBars];
    CGFloat barHeightPercentage = (float)[dataPointForBarIndex integerValue] / self.largestPoint;
    return barHeightPercentage;
}

/**
 *  Returns a dataPoint corresponding to the appropriate barIndex. If totalBars is greater than or equal to the number of data points the HistogramDataSource was initialized with the raw value will be returned. If totalBars is less than than number of dataPointsthe HistogramDataSource was initialized with an average value will be calculated for the barIndex relative to the totalBars and returned.
 */
- (NSNumber *)dataPointForBarIndex:(NSInteger)barIndex
                     WithTotalBars:(NSInteger)totalBars
{
    if ( totalBars >= (NSInteger)self.dataPoints.count )
    {
        float percentThroughTimeline = (float) barIndex / (totalBars);
        NSUInteger dataPointIndex = (percentThroughTimeline * (self.dataPoints.count));
        return [self.dataPoints objectAtIndex:dataPointIndex];
    }
    
    CGFloat dataPointsPerBar = (float) self.dataPoints.count / totalBars;
    NSInteger total = 0;
    for (NSUInteger dataPointIndex = (barIndex *dataPointsPerBar); dataPointIndex < ((barIndex *dataPointsPerBar) + dataPointsPerBar); dataPointIndex++)
    {
        if (dataPointIndex  >= self.dataPoints.count)
        {
            break;
        }
        total = total + [[self.dataPoints objectAtIndex:dataPointIndex] integerValue];
    }
    CGFloat average = (float) total / (NSInteger) dataPointsPerBar;

    return @( average );
}

@end
