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

- (NSString *)v_firstNonSlashPathComponent
{
    return [self v_nonSlashPathComponentAtIndex:0];
}

- (NSString *)v_nonSlashPathComponentAtIndex:(NSUInteger)index
{
    NSUInteger count = 0;
    for (NSString *pathComponent in self.pathComponents)
    {
        if ( ![pathComponent isEqualToString:kPathSeparator] )
        {
            if ( count == index )
            {
                return pathComponent;
            }
            else
            {
                count++;
            }
        }
    }
    return nil;
}

- (NSString *)v_pathComponentAtIndex:(NSUInteger)index
{
    if ( index < self.pathComponents.count )
    {
        return self.pathComponents[ index ];
    }
    
    return nil;
}

@end
