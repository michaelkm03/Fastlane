//
//  VCoachmark.m
//  victorious
//
//  Created by Sharif Ahmed on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCoachmark.h"

@implementation VCoachmark

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
#warning DO the dance
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
#warning COMPLETE
    self = [super init];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
#warning COMPLETE
}

- (BOOL)isEqualToCoachmark:(VCoachmark *)coachmark
{
    return [coachmark.remoteId isEqualToString:self.remoteId];
}

- (BOOL)isEqual:(id)object
{
    if ( object == self )
    {
        return YES;
    }
    if ( ![object isKindOfClass:[VCoachmark class]] )
    {
        return NO;
    }
    return [self isEqualToCoachmark:object];
}

- (NSUInteger)hash
{
    return [self.remoteId hash];
}

@end
