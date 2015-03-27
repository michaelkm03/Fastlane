//
//  VCropWorkspaceToolViewController.m
//  victorious
//
//  Created by Michael Sena on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCropToolViewController.h"

#import "UIScrollView+VCenterContent.h"

@interface VCropToolViewController () <UIScrollViewDelegate>

@end

@implementation VCropToolViewController

+ (instancetype)cropViewController
{
    UIStoryboard *workspaceStoryboard = [UIStoryboard storyboardWithName:@"Workspace"
                                                                  bundle:nil];
    VCropToolViewController *cropTool = [workspaceStoryboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];

    return cropTool;
}

#pragma mark - UIViewController
#pragma mark Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.userInteractionEnabled = NO;
}

@end
