//
//  NSURL+VPathHelper.m
//  victorious
//
//  Created by Josh Hinman on 1/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSURL+VPathHelper.h"

static NSString * const kPathSeparator = @"/";

@implementation NSURL (VPathHelper)

- (NSString *)firstNonSlashPathComponent
{
    for (NSString *pathComponent in self.pathComponents)
    {
        if ( ![pathComponent isEqualToString:kPathSeparator] )
        {
            return pathComponent;
        }
    }
    return nil;
}

@end
