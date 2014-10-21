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

+ (instancetype)histogramDataSourceWithDataPoints:(NSArray *)dataPoints
{
    BOOL hasEnoughData = dataPoints.count > 0;
    NSParameterAssert(hasEnoughData);
    if (!hasEnoughData)
    {
        return nil;
    }
    
    for (id obj in dataPoints)
    {
        BOOL isEachDataPointAnNSNumber = [obj isKindOfClass:[NSNumber class]];
        NSParameterAssert(isEachDataPointAnNSNumber);
        if (!isEachDataPointAnNSNumber)
        {
            return nil;
        }
        NSNumber *point = (NSNumber *)obj;
        BOOL isEachDataPointGreatThanOrEqualToZero = [point integerValue] >= 0;
        NSParameterAssert(isEachDataPointGreatThanOrEqualToZero);
        if (!isEachDataPointGreatThanOrEqualToZero)
        {
            return nil;
        }
    };
    
    return [[VHistogramDataSource alloc] initWithDataPoints:dataPoints];
}

- (instancetype)initWithDataPoints:(NSArray *)dataPoints
{
    self = [super init];
    if (self)
    {
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
    CGFloat barHeightPercentage = (CGFloat)[dataPointForBarIndex integerValue] / self.largestPoint;
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
    NSUInteger dataPointStartingIndex = (barIndex *dataPointsPerBar);
    NSUInteger dataPointLastIndex = ((barIndex *dataPointsPerBar) + dataPointsPerBar);
    for (NSUInteger dataPointIndex = dataPointStartingIndex; dataPointIndex < dataPointLastIndex; dataPointIndex++)
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
