//
//  VDependencyManager+VCoachmarkManager.m
//  victorious
//
//  Created by Sharif Ahmed on 5/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager+VCoachmarkManager.h"
#import "VDependencyManager+VScaffoldViewController.h"
#import "VScaffoldViewController.h"

NSString * const VLikeButtonCoachmarkIdentifier = @"like_button_coachmark";

@implementation VDependencyManager (VCoachmarkManager)

- (VCoachmarkManager *)coachmarkManager
{
    return [[self scaffoldViewController] coachmarkManager];
}

@end
