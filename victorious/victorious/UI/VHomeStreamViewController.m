//
//  VHomeStreamViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHomeStreamViewController.h"
#import "VConstants.h"

@interface VHomeStreamViewController ()

@end

@implementation VHomeStreamViewController

- (NSArray*)categoriesForOption:(NSUInteger)searchOption
{
    switch (searchOption)
    {
        case VStreamFilterPolls:
            return @[kVOwnerPollCategory, kVUGCPollCategory];
            
        case VStreamFilterImages:
            return @[kVOwnerImageCategory, kVUGCImageCategory];
            
        case VStreamFilterVideos:
            return @[kVOwnerVideoCategory, kVUGCVideoCategory];
            
        default:
            return @[kVOwnerPollCategory, kVUGCPollCategory, kVOwnerImageCategory,
                     kVUGCImageCategory, kVOwnerVideoCategory, kVUGCVideoCategory];
    }
}

@end
