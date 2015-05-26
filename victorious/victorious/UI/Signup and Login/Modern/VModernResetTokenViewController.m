//
//  VModernResetTokenViewController.m
//  victorious
//
//  Created by Michael Sena on 5/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VModernResetTokenViewController.h"

@interface VModernResetTokenViewController ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VModernResetTokenViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSBundle *bundleForClass = [NSBundle bundleForClass:self];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass(self)
                                                         bundle:bundleForClass];
    VModernResetTokenViewController *resetTokenViewController = [storyboard instantiateInitialViewController];
    resetTokenViewController.dependencyManager = dependencyManager;
    return resetTokenViewController;
}

@end
