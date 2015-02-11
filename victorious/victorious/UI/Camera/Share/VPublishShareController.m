//
//  VPublishShareController.m
//  victorious
//
//  Created by Josh Hinman on 8/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPublishShareController.h"

@implementation VPublishShareController

- (void)shareButtonTapped
{
    NSAssert(false, @"Implement in subclasses!");
}

- (void)setSwitchToConfigure:(UISwitch *)switchToConfigure
{
    _switchToConfigure = switchToConfigure;
    
    [switchToConfigure addTarget:self
                          action:@selector(shareButtonTapped)
                forControlEvents:UIControlEventValueChanged];
}

@end
