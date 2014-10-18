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

/**
 Initializes a new VHistogramDataSource.
 
 @param dataPoints An array of NSValue wrapped NSIntegers.
 
 @return an initialized VHistogramDataSource.
 */
- (instancetype)initWithDataPoints:(NSArray *)dataPoints;

@end
