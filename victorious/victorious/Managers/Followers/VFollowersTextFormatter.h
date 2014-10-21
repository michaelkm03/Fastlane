//
//  VFollowersTextFormatter.h
//  victorious
//
//  Created by Patrick Lynch on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VFollowersTextFormatter : NSObject

+ (NSString *)shortLabelWithNumberOfFollowersObject:(NSNumber *)numFollowers;

+ (NSString *)shortLabelWithNumberOfFollowers:(NSUInteger)numFollowers;

@end
