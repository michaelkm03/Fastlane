//
//  VPollCreationFlowController.m
//  victorious
//
//  Created by Michael Sena on 7/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPollCreationFlowController.h"

// Dependencies
#import "VDependencyManager.h"
#import "VCreatePollViewController.h"

static NSString * const kPollCreationScreenKey = @"pollCreationScreen";

@interface VPollCreationFlowController ()

@end

@implementation VPollCreationFlowController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    VCreatePollViewController *pollViewController = [self.dependencyManager templateValueOfType:[VCreatePollViewController class]
                                                                                         forKey:kPollCreationScreenKey];
    [self addCloseButtonToViewController:pollViewController];
    [self pushViewController:pollViewController animated:YES];
}

@end
