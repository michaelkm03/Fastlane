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

@implementation VStreamTableViewController (ContentCreation)

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
                                      VCreatePollViewController *createViewController = [VCreatePollViewController newCreatePollViewControllerWithDelegate:self];
                                      [self.navigationController pushViewController:createViewController animated:YES];
                                  }, nil];
    [actionSheet showInView:self.view];
}

- (void)presentCameraViewController:(VCameraViewController *)cameraViewController
{
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    UINavigationController * __weak weakNav = navigationController;
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

- (void)createPollWithQuestion:(NSString *)question
                   answer1Text:(NSString *)answer1Text
                   answer2Text:(NSString *)answer2Text
                     media1URL:(NSURL *)media1URL
                     media2URL:(NSURL *)media2URL
{
    
    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        NSLog(@"%@", resultObjects);
    };
    VFailBlock fail = ^(NSOperation* operation, NSError* error)
    {
        NSLog(@"%@", error);
        NSString *title, *message;
        
        if(kVUserBannedError == error.code)
        {
            title = NSLocalizedString(@"UserBannedTitle", @"");
            message = NSLocalizedString(@"UserBannedMessage", @"");
        }
        else if (kVStillTranscodingError == error.code)
        {
            title = NSLocalizedString(@"TranscodingMediaTitle", @"");
            message = NSLocalizedString(@"TranscodingMediaBody", @"");
        }
        else
        {
            title = NSLocalizedString(@"PollUploadTitle", @"");
            message = error.localizedDescription;
        }
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
        [alert show];
    };
    [[VObjectManager sharedManager] createPollWithName:question
                                           description:@"<none>"
                                              question:question
                                           answer1Text:answer1Text
                                           answer2Text:answer2Text
                                            media1Url:media1URL
                                            media2Url:media2URL
                                          successBlock:success
                                             failBlock:fail];
}

@end
