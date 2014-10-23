//
//  VExperienceEnhancer.m
//  victorious
//
//  Created by Michael Sena on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VExperienceEnhancer.h"
#import "VVoteType+Fetcher.h"

@implementation VExperienceEnhancer

+ (NSArray *)sortedExperienceEnhancers:(NSArray *)unsorted
{
    return [unsorted sortedArrayWithOptions:0
                            usingComparator:^NSComparisonResult(VExperienceEnhancer *exp1, VExperienceEnhancer *exp2)
            {
                return [exp1.voteType.displayOrder compare:exp2.voteType.displayOrder];
            }];
}

- (instancetype)initWithVoteType:(VVoteType *)voteType
{
    self = [super init];
    if (self)
    {
        _voteType = voteType;
        
        self.labelText = voteType.name;
        self.contentMode = voteType.contentMode;
        self.flightDuration = (float)voteType.flightDuration.unsignedIntegerValue / 1000.0f;
        self.animationDuration = (float)voteType.animationDuration.unsignedIntegerValue / 1000.0f;
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
    return self.flightImage && self.flightDuration > 0.0;
}

@end
