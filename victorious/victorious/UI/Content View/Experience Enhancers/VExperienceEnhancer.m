//
//  VExperienceEnhancer.m
//  victorious
//
//  Created by Michael Sena on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VExperienceEnhancer.h"

@implementation VExperienceEnhancer

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

@end
