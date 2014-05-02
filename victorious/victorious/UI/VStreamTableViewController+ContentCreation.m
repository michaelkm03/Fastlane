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

#import "VObjectManager+Sequence.h"
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
    if(![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    NSString *contentTitle = NSLocalizedString(@"Post Content", @"Post content button");
    NSString *pollTitle = NSLocalizedString(@"Post Poll", @"Post poll button");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
                                                       onCancelButton:nil
                                               destructiveButtonTitle:nil
                                                  onDestructiveButton:nil
                                           otherButtonTitlesAndBlocks:contentTitle, ^(void)
                                  {
                                      UINavigationController *navigationController = [[UINavigationController alloc] init];
                                      UINavigationController * __weak weakNav = navigationController;
                                      VCameraViewController *cameraViewController = [VCameraViewController cameraViewController];
                                      cameraViewController.completionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL, NSString *mediaExtension)
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
                                  },
                                  pollTitle, ^(void)
                                  {
                                      VCreatePollViewController *createViewController = [VCreatePollViewController newCreatePollViewControllerWithDelegate:self];
                                      [self.navigationController pushViewController:createViewController animated:YES];
                                  }, nil];
    [actionSheet showInView:self.view];
}

- (void)createPollWithQuestion:(NSString *)question
                   answer1Text:(NSString *)answer1Text
                   answer2Text:(NSString *)answer2Text
                     media1URL:(NSURL *)media1URL
                     media2URL:(NSURL *)media2URL
{
    __block NSURL* firstRemovalURL = media1URL;
    __block NSURL* secondRemovalURL = media2URL;
    
    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        NSLog(@"%@", resultObjects);
        
        [[NSFileManager defaultManager] removeItemAtURL:firstRemovalURL error:nil];
        [[NSFileManager defaultManager] removeItemAtURL:secondRemovalURL error:nil];
    };
    VFailBlock fail = ^(NSOperation* operation, NSError* error)
    {
        NSLog(@"%@", error);
        
        [[NSFileManager defaultManager] removeItemAtURL:firstRemovalURL error:nil];
        [[NSFileManager defaultManager] removeItemAtURL:secondRemovalURL error:nil];
        
        if (5500 == error.code)
        {
            UIAlertView*    alert   = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TranscodingMediaTitle", @"")
                                                                 message:NSLocalizedString(@"TranscodingMediaBody", @"")
                                                                delegate:nil
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
            [alert show];
        }
        else
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PollUploadTitle", @"")
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
            [alert show];
        }
    };
    
    [[VObjectManager sharedManager] createPollWithName:question
                                           description:@"<none>"
                                              question:question
                                           answer1Text:answer1Text
                                           answer2Text:answer2Text
                                            media1Url:media1URL
                                       media1Extension:[media1URL pathExtension]
                                            media2Url:media2URL
                                       media2Extension:[media2URL pathExtension]
                                          successBlock:success
                                             failBlock:fail];
}

@end
