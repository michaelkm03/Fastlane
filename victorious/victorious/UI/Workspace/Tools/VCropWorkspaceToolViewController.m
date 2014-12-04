//
//  VCropWorkspaceToolViewController.m
//  victorious
//
//  Created by Michael Sena on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCropWorkspaceToolViewController.h"

@interface VCropWorkspaceToolViewController ()

@end

@implementation VCropWorkspaceToolViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *workspaceStoryboard = [UIStoryboard storyboardWithName:@"Workspace"
                                                                  bundle:nil];
    VCropWorkspaceToolViewController *cropTool = [workspaceStoryboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];

    return cropTool;
}

@end
