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

+ (VCommunityStreamViewController *)sharedInstance
{
    static  VCommunityStreamViewController*   sharedInstance;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        sharedInstance = (VCommunityStreamViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kCommunityStreamStoryboardID];
    });
    
    return sharedInstance;
}

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
