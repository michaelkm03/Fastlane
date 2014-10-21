//
//  VExperienceEnhancer.m
//  victorious
//
//  Created by Michael Sena on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VExperienceEnhancer.h"
#import "VVoteType.h"

@implementation VExperienceEnhancer

- (instancetype)initWithVoteType:(VVoteType *)voteType
{
    self = [super init];
    if (self) {
        _voteType = voteType;
        
        self.labelText = voteType.name;
        self.flightDuration = voteType.flightDuration.floatValue;
        self.animationDuration = voteType.animationDuration.floatValue;
    }
    return self;
}

- (BOOL)hasRequiredImages
{
    if ( self.isBallistic )
    {
        return self.flightImage != nil;
    }
    else
    {
        return self.iconImage != nil && self.animationSequence != nil && self.animationSequence.count > 0;
    }
}

- (BOOL)isBallistic
{
    return self.flightImage != nil && self.flightDuration > 0.0;
}

@end
