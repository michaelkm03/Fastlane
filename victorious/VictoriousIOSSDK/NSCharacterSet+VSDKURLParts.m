//
//  NSCharacterSet+VSDKURLParts.m
//  victorious
//
//  Created by Josh Hinman on 2/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSCharacterSet+VSDKURLParts.h"

@implementation NSCharacterSet (VURLParts)

+ (NSCharacterSet *)vsdk_pathPartCharacterSet
{
    static NSCharacterSet *pathPartCharacterSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      NSMutableCharacterSet *mutableCharacterSet = [[NSCharacterSet URLPathAllowedCharacterSet] mutableCopy];
                      [mutableCharacterSet removeCharactersInString:@"/@:"];
                      pathPartCharacterSet = [mutableCharacterSet copy];
                  });
    return pathPartCharacterSet;
}

+ (NSCharacterSet *)vsdk_queryPartCharacterSet
{
    static NSCharacterSet *queryPartCharacterSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      NSMutableCharacterSet *mutableCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
                      [mutableCharacterSet removeCharactersInString:@"?&=@"];
                      queryPartCharacterSet = [mutableCharacterSet copy];
                  });
    return queryPartCharacterSet;
}

@end
