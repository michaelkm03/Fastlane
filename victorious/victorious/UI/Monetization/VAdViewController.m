//
//  VAdViewController.m
//  victorious
//
//  Created by Lawrence Leach on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAdViewController.h"

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
    return NO;
}

- (void)startAdManager
{
    NSAssert(NO, @"class %@ needs to implement startAdManager:", NSStringFromClass([self class]));
}

@end
