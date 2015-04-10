//
//  VRTCUserPostedAtFormatter.h
//  victorious
//
//  Created by Michael Sena on 8/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDependencyManager;

@interface VRTCUserPostedAtFormatter : NSObject

+ (NSAttributedString *)formatRTCUserName:(NSString *)username
                    withDependencyManager:(VDependencyManager *)dependencyManager;
+ (NSAttributedString *)formattedRTCUserPostedAtStringWithUserName:(NSString *)username
                                                     andPostedTime:(NSNumber *)postedTime
                                             withDependencyManager:(VDependencyManager *)dependencyManager;

@end
