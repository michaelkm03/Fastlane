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

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VPollCreationFlowController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    VCreatePollViewController *pollViewController = [self.dependencyManager templateValueOfType:[VCreatePollViewController class]
                                                                                         forKey:kPollCreationScreenKey];
    [self pushViewController:pollViewController animated:YES];
}

@end
