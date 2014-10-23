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

+ (NSArray *)experienceEnhancersSortedByDisplayOrder:(NSArray *)enhancers
{
    return [enhancers sortedArrayWithOptions:0
                            usingComparator:^NSComparisonResult(VExperienceEnhancer *exp1, VExperienceEnhancer *exp2)
            {
                return [exp1.voteType.displayOrder compare:exp2.voteType.displayOrder];
            }];
}

+ (NSArray *)experienceEnhancersFilteredByHasRequiredImages:(NSArray *)enhancers
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(VExperienceEnhancer *enhancer,
                                                                   NSDictionary *bindings)
                              {
                                  return enhancer.hasRequiredImages;
                              }];
    return [enhancers filteredArrayUsingPredicate:predicate];
}

- (instancetype)initWithVoteType:(VVoteType *)voteType
{
    self = [super init];
    if (self)
    {
        _voteType = voteType;
        
        self.contentMode = voteType.contentMode;
        self.flightDuration = (float)voteType.flightDuration.unsignedIntegerValue / 1000.0f;
        self.animationDuration = (float)voteType.animationDuration.unsignedIntegerValue / 1000.0f;
    }
    return self;
}

- (BOOL)hasRequiredImages
{
    if ( self.isBallistic && self.flightImage == nil )
    {
        return NO;
    }
    else
    {
        return self.iconImage != nil && self.animationSequence != nil && self.animationSequence.count > 0;
    }
}

- (BOOL)isBallistic
{
    return self.flightDuration > 0.0;
}

@end
