//
//  VImageVideoLibraryViewController.m
//  victorious
//
//  Created by Michael Sena on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageVideoLibraryViewController.h"

@interface VImageVideoLibraryViewController ()

@end

@implementation VImageVideoLibraryViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VImageVideoLibraryViewController *galleryViewController = (VImageVideoLibraryViewController *)[[UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:[NSBundle bundleForClass:self]] instantiateInitialViewController];
    return galleryViewController;
}

#pragma mark - Target/Action

- (IBAction)tappedCamera:(id)sender
{
    if (self.userSelectedCamera != nil)
    {
        self.userSelectedCamera();
    }
}

- (IBAction)tappedSearch:(id)sender
{
    
}

@end
