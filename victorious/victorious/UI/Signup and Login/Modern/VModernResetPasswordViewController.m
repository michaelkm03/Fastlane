//
//  VModernResetPasswordViewController.m
//  victorious
//
//  Created by Michael Sena on 5/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VModernResetPasswordViewController.h"

@interface VModernResetPasswordViewController ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VModernResetPasswordViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSBundle *bundleForClass = [NSBundle bundleForClass:self];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass(self)
                                                         bundle:bundleForClass];
    VModernResetPasswordViewController *resetPasswordViewController = [storyboard instantiateInitialViewController];
    resetPasswordViewController.dependencyManager = dependencyManager;
    return resetPasswordViewController;
}

@end
