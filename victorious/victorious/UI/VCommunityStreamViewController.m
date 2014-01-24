//
//  VCommunityStreamViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCommunityStreamViewController.h"
#import "VConstants.h"

@interface VCommunityStreamViewController ()

@end

@implementation VCommunityStreamViewController

- (NSArray*)categoriesForOption:(NSUInteger)searchOption
{
    switch (searchOption)
    {
        case VStreamFilterPolls:
            return @[kVUGCPollCategory];
            
        case VStreamFilterImages:
            return @[kVUGCImageCategory];
            
        case VStreamFilterVideos:
            return @[kVUGCVideoCategory];
            
        default:
            return @[kVUGCPollCategory, kVUGCImageCategory, kVUGCVideoCategory];
    }
}
@end
