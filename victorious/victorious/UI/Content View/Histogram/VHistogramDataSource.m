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
    float percentThroughTimeline = (float) barIndex / (totalBars);
    NSUInteger dataPointIndex = (percentThroughTimeline * (self.dataPoints.count));
    NSNumber *dataPointForBarIndex = [self.dataPoints objectAtIndex:dataPointIndex];
    
    CGFloat barHeightPercentage = (float)[dataPointForBarIndex integerValue] / self.largestPoint;
    return barHeightPercentage;
}

@end
