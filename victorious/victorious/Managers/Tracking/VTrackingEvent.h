//
//  VTrackingEvent.h
//  victorious
//
//  Created by Patrick Lynch on 10/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VTrackingEvent : NSObject

- (instancetype)initWithName:(NSString *)name parameters:(NSDictionary *)parameters key:(id)key;

@property (nonatomic, readonly) id key;
@property (nonatomic, readonly) NSDictionary *parameters;
@property (nonatomic, readonly) NSString *name;

@end