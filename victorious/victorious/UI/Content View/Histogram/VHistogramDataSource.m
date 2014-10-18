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

@end

@implementation VHistogramDataSource

- (instancetype)initWithDataPoints:(NSArray *)dataPoints
{
    self = [super init];
    if (self)
    {
        [dataPoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
        {
            NSAssert([obj isKindOfClass:[NSValue class]], @"Must pass in an array of NSValue wrapped NSIntegers");
            NSNumber *point = (NSNumber *)obj;
            NSAssert(([point integerValue] > 0), @"Must pass in positive values");
        }];
    }
    return self;
}

#pragma mark - VHistogramDataSource

- (NSInteger)numberOfSlicesForHistogramView:(VHistogramView *)histogramView
{
    return 0;
}

- (CGFloat)histogramPercentageHeight:(VHistogramView *)histogramView
                       forSliceIndex:(NSInteger)sliceIndex
{
    return 0.0f;
}

@end
