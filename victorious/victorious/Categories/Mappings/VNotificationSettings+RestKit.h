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

/**
 Returns a serialized dictinoary representation of this object ready to send
 to the server when preferences are saved.  If any value is undefined, it
 will default to @NO.
 */
@property (nonatomic, readonly) NSDictionary *parametersDictionary;

@end
