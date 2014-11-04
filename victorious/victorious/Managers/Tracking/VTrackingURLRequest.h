//
//  VTrackingURLRequest.h
//  victorious
//
//  Created by Patrick Lynch on 10/31/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VTrackingURLRequest : NSMutableURLRequest

@property (nonatomic, assign) NSUInteger retriesCount;

@end
