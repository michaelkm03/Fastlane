//
//  VAdViewController.m
//  victorious
//
//  Created by Lawrence Leach on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAdViewController.h"
#import "VLiveRailsAdViewController.h"
#import "VConstants.h"

static BOOL kIsAdPlaying = NO;  //< Default flag for ad playback

@interface VAdViewController ()

@end

@implementation VAdViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        
    }
    return self;
}

- (BOOL)isAdPlaying
{
    return kIsAdPlaying;
}

- (void)startAdManager
{
    NSAssert(NO, @"class %@ needs to implement startAdManager:", NSStringFromClass([self class]));
}

@end
