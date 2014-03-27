//
//  VCommunityStreamViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCommunityStreamViewController.h"
#import "VConstants.h"

#import "UIActionSheet+BBlock.h"
#import "VObjectManager+Sequence.h"
#import "VCreatePollViewController.h"
#import "VLoginViewController.h"
#import "VCameraViewController.h"

@interface VCommunityStreamViewController () <VCreateSequenceDelegate>

@end

@implementation VCommunityStreamViewController

+ (VCommunityStreamViewController *)sharedInstance
{
    static  VCommunityStreamViewController*   sharedInstance;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        sharedInstance = (VCommunityStreamViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kCommunityStreamStoryboardID];
    });
    
    return sharedInstance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                   target:self
                                                                                   action:@selector(addButtonAction:)];
    

    self.navigationItem.rightBarButtonItem = addButtonItem;//@[addButtonItem, self.navigationItem.rightBarButtonItem];
}

- (NSArray*)categoriesForOption:(NSUInteger)searchOption
{
    switch (searchOption)
    {
        case VStreamFilterPolls:
            return @[kVUGCPollCategory];
            
        case VStreamFilterImages:
            return @[kVUGCImageCategory];
            
        case VStreamFilterVideos:
            return @[kVUGCVideoCategory];
            
        default:
            return @[kVUGCPollCategory, kVUGCImageCategory, kVUGCVideoCategory];
    }
}


- (IBAction)addButtonAction:(id)sender
{
    if(![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    NSString *contentTitle = NSLocalizedString(@"Post Content", @"Post content button");
    NSString *pollTitle = NSLocalizedString(@"Post Poll", @"Post poll button");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:contentTitle, pollTitle, nil];
    [actionSheet setCompletionBlock:^(NSInteger buttonIndex, UIActionSheet *actionSheet)
     {
         if(actionSheet.cancelButtonIndex == buttonIndex)
         {
             return;
         }
         
         //TODO: share 
         if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:contentTitle])
         {
             [self presentViewController:[VCameraViewController cameraViewController] animated:YES completion:nil];
         }
         else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:pollTitle])
         {
             VCreatePollViewController *createViewController = [VCreatePollViewController newCreatePollViewControllerForType:VImagePickerViewControllerPhotoAndVideo withDelegate:self];
             
             [self.navigationController pushViewController:createViewController animated:YES];
         }
     }];
    [actionSheet showInView:self.view];
}

- (void)createPollWithQuestion:(NSString *)question
                   answer1Text:(NSString *)answer1Text
                   answer2Text:(NSString *)answer2Text
                    media1Data:(NSData *)media1Data
               media1Extension:(NSString *)media1Extension
                    media2Data:(NSData *)media2Data
               media2Extension:(NSString *)media2Extension
{
    __block UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(0, 0, 24, 24);
    [self.view addSubview:indicator];
    indicator.center = self.view.center;
    [indicator startAnimating];
    indicator.hidesWhenStopped = YES;
    
    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        NSLog(@"%@", resultObjects);
        [indicator stopAnimating];
        [self.navigationController popViewControllerAnimated:YES];
    };
    VFailBlock fail = ^(NSOperation* operation, NSError* error)
    {
        NSLog(@"%@", error);
        [indicator stopAnimating];
        
        if (5500 == error.code)
        {
            UIAlertView*    alert   = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TranscodingMediaTitle", @"")
                                                                 message:NSLocalizedString(@"TranscodingMediaBody", @"")
                                                                delegate:nil
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
            [alert show];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PollUploadTitle", @"")
                                                            message:NSLocalizedString(@"PollUploadBody", @"")
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
            [alert show];
        }
    };
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [[VObjectManager sharedManager] createPollWithName:question
                                           description:@"<none>"
                                              question:question
                                           answer1Text:answer1Text
                                           answer2Text:answer2Text
                                            media1Data:media1Data
                                       media1Extension:media1Extension
                                             media1Url:nil
                                            media2Data:media2Data
                                       media2Extension:media2Extension
                                             media2Url:nil
                                          successBlock:success
                                             failBlock:fail];
}
//
//
//- (void)createPostwithMessage:(NSString *)message
//                         data:(NSData *)data
//                    mediaType:(NSString *)mediaType
//{
//    __block UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    indicator.frame = CGRectMake(0, 0, 24, 24);
//    [self.view addSubview:indicator];
//    indicator.center = self.view.center;
//    [indicator startAnimating];
//    indicator.hidesWhenStopped = YES;
//    
//    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
//    {
//        NSLog(@"%@", resultObjects);
//        [indicator stopAnimating];
//        [self.tableView reloadData];
//        [self.navigationController popViewControllerAnimated:YES];
//    };
//    VFailBlock fail = ^(NSOperation* operation, NSError* error)
//    {
//        NSLog(@"%@", error);
//        [indicator stopAnimating];
//        
//        if (5500 == error.code)
//        {
//            UIAlertView*    alert   = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TranscodingMediaTitle", @"")
//                                                                 message:NSLocalizedString(@"TranscodingMediaBody", @"")
//                                                                delegate:nil
//                                                       cancelButtonTitle:nil
//                                                       otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
//            [alert show];
//        }
//        else
//        {
//            UIAlertView*    alert   = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UploadError", @"")
//                                                                 message:NSLocalizedString(@"UploadErrorBody", @"")
//                                                                delegate:nil
//                                                       cancelButtonTitle:nil
//                                                       otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
//            [alert show];
//        }
//    };
//    
//    [[VObjectManager sharedManager] uploadMediaWithName:message
//                                            description:message
//                                              expiresAt:nil
//                                           parentNodeId:nil
//                                               loopType:VLoopOnce
//                                           shareOptions:VShareNone
//                                              mediaData:data
//                                              extension:mediaType
//                                               mediaUrl:nil
//                                           successBlock:success
//                                              failBlock:fail];
//}

@end
