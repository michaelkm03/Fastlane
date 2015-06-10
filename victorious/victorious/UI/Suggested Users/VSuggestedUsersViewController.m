//
//  VSuggestedUsersViewController.m
//  victorious
//
//  Created by Patrick Lynch on 6/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSuggestedUsersViewController.h"
#import "VDependencyManager+VBackgroundContainer.h"

@interface VSuggestedUsersViewController () <VBackgroundContainer>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VSuggestedUsersViewController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.dependencyManager addBackgroundToBackgroundHost:self];
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self.view;
}

@end
