//
//  VNotificationSettings+RestKit.h
//  victorious
//
//  Created by Patrick Lynch on 11/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VNotificationSettings.h"

@interface VNotificationSettings (RestKit)

+ (NSArray *)descriptors;

+ (NSString *)entityName;

+ (RKEntityMapping *)entityMapping;

@property (nonatomic, readonly) NSDictionary *parametersDictionary;

@end
