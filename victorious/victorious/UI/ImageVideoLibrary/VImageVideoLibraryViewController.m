//
//  VImageVideoLibraryViewController.m
//  victorious
//
//  Created by Michael Sena on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageVideoLibraryViewController.h"

@interface VImageVideoLibraryViewController () <UIPopoverPresentationControllerDelegate>

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

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"albumsPopover"])
    {
        // Set delegate to self so we can show as a real popover (Non-adaptive).
        UIViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.popoverPresentationController.delegate = self;
        // Inset the popover a bit
        CGSize preferredContentSize = CGSizeMake(CGRectGetWidth(self.view.bounds) - 50.0f,
                                                 CGRectGetHeight(self.view.bounds) - 200.0f);
        destinationViewController.preferredContentSize = preferredContentSize;
    }
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
                                                               traitCollection:(UITraitCollection *)traitCollection
{
    return UIModalPresentationNone;
}

@end
