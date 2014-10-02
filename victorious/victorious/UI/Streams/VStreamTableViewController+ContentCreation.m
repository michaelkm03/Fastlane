//
//  VStreamTableViewController+ContentCreation.m
//  victorious
//
//  Created by Will Long on 4/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamTableViewController+ContentCreation.h"

#import "UIActionSheet+VBlocks.h"

#import "VCameraPublishViewController.h"
#import "VCameraViewController.h"

#import "VLoginViewController.h"

#import "VObjectManager+ContentCreation.h"
#import "VCreatePollViewController.h"

#import "VFindFriendsViewController.h"

@implementation VStreamTableViewController (ContentCreation)

- (void)addFriendsButton
{

    
    UIBarButtonItem *friendsButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"findFriendsIcon"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(findFriendsAction:)];
    
    self.navigationItem.rightBarButtonItems =  [@[friendsButtonItem] arrayByAddingObjectsFromArray:self.navigationItem.rightBarButtonItems];
    
}

- (IBAction)findFriendsAction:(id)sender
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }

    VFindFriendsViewController *ffvc = [VFindFriendsViewController newFindFriendsViewController];
    [ffvc setShouldAutoselectNewFriends:NO];
    [self.navigationController pushViewController:ffvc animated:YES];
}

- (void)addCreateButton
{
    
    UIBarButtonItem *createButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"createContentButton"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(createButtonAction:)];
    
    self.navigationItem.rightBarButtonItems =  [@[createButtonItem] arrayByAddingObjectsFromArray:self.navigationItem.rightBarButtonItems];
}

- (IBAction)createButtonAction:(id)sender
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
                                                       onCancelButton:nil
                                               destructiveButtonTitle:nil
                                                  onDestructiveButton:nil
                                           otherButtonTitlesAndBlocks:
                                  NSLocalizedString(@"Create a Video Post", @""), ^(void)
                                  {
                                      [self presentCameraViewController:[VCameraViewController cameraViewController]];
                                  },
                                  NSLocalizedString(@"Create an Image Post", @""), ^(void)
                                  {
                                      [self presentCameraViewController:[VCameraViewController cameraViewControllerStartingWithStillCapture]];
                                  },
                                  NSLocalizedString(@"Create a Poll", @""), ^(void)
                                  {
                                      VCreatePollViewController *createViewController = [VCreatePollViewController newCreatePollViewController];
                                      [self.navigationController pushViewController:createViewController animated:YES];
                                  }, nil];
    [actionSheet showInView:self.view];
}

- (void)presentCameraViewController:(VCameraViewController *)cameraViewController
{
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    UINavigationController *__weak weakNav = navigationController;
    cameraViewController.completionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        if (!finished || !capturedMediaURL)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            VCameraPublishViewController *publishViewController = [VCameraPublishViewController cameraPublishViewController];
            publishViewController.previewImage = previewImage;
            publishViewController.mediaURL = capturedMediaURL;
            publishViewController.completion = ^(BOOL complete)
            {
                if (complete)
                {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                else
                {
                    [weakNav popViewControllerAnimated:YES];
                }
            };
            [weakNav pushViewController:publishViewController animated:YES];
        }
    };
    [navigationController pushViewController:cameraViewController animated:NO];
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end
