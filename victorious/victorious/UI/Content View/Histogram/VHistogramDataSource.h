//
//  VHistogramDataSource.h
//  victorious
//
//  Created by Michael Sena on 10/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VHistogramBarView.h"

@interface VHistogramDataSource : NSObject <VHistogramBarViewDataSource>

// Returns nil if bad data
+ (instancetype)histogramDataSourceWithDataPoints:(NSArray *)dataPoints;

@end
