//
//  VVideoTool.m
//  victorious
//
//  Created by Michael Sena on 12/31/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVideoTool.h"

#import "VTrimmerViewController.h"

@interface VVideoTool ()

@property (nonatomic, strong) VTrimmerViewController *trimViewController;

@end

@implementation VVideoTool

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.trimViewController = [[VTrimmerViewController alloc] initWithNibName:nil
                                                                           bundle:nil];
    }
    return self;
}

- (UIViewController *)inspectorToolViewController
{
    return self.trimViewController;
}

- (NSString *)title
{
    return @"Video";
}

@end
