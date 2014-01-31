//
//  VHomeStreamViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHomeStreamViewController.h"
#import "VConstants.h"

#import "VCreateViewController.h"

@interface VHomeStreamViewController ()
@end

@implementation VHomeStreamViewController

+ (VHomeStreamViewController *)sharedInstance
{
    static  VHomeStreamViewController*   sharedInstance;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        sharedInstance = (VHomeStreamViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kHomeStreamStoryboardID];
    });
    
    return sharedInstance;
}

- (void) viewDidLoad
{
    self.usesFeaturedVideos = YES;
    [super viewDidLoad];
    
    UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VCreateViewController* createView = (VCreateViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([VCreateViewController class])];
    createView.delegate = self;
    createView.type = VImagePickerViewControllerPhoto;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:createView] animated:YES completion:nil];
}

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
