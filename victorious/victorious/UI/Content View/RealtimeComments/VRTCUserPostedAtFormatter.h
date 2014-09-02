//
//  VRTCUserPostedAtFormatter.h
//  victorious
//
//  Created by Michael Sena on 8/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VRTCUserPostedAtFormatter : NSObject

+ (NSAttributedString*)formatRTCUserName:(NSString*)username;
+ (NSAttributedString *)formattedRTCUserPostedAtStringWithUserName:(NSString *)username
                                                     andPostedTime:(NSNumber *)postedTime;

@end
