//
//  VMessageSubViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIImage+ImageEffects.h"
#import "UIImageView+Blurring.h"
#import "VMessageContainerViewController.h"
#import "VMessageViewController.h"
#import "VObjectManager.h"
#import "VObjectManager+ContentCreation.h"
#import "VObjectManager+DirectMessaging.h"
#import "VConversation.h"
#import "VThemeManager.h"
#import "VUser.h"
#import "NSString+VParseHelp.h"

#import "UIActionSheet+VBlocks.h"

#import "MBProgressHUD.h"

@interface VMessageContainerViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIButton    *backButton;
@property (nonatomic, weak) IBOutlet UILabel     *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton    *moreButton;

@end

@implementation VMessageContainerViewController
@synthesize conversationTableViewController = _conversationTableViewController;


+ (instancetype)messageContainer
{
    UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VMessageContainerViewController* container = (VMessageContainerViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kMessageContainerID];
    
    return container;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *moreImage = [self.moreButton imageForState:UIControlStateNormal];
    [self.moreButton setImage:[moreImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    UIImage *backImage = [self.backButton imageForState:UIControlStateNormal];
    [self.backButton setImage:[backImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];

    [self addBackgroundImage];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    VMessageViewController* messageVC = (VMessageViewController*)self.conversationTableViewController;
    self.navigationItem.title = messageVC.otherUser.name ?: @"Message";
}

- (IBAction)flagConversation:(id)sender
{
    NSString *reportTitle = NSLocalizedString(@"Report Inappropriate", @"Comment report inappropriate button");
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
                                                       onCancelButton:nil
                                               destructiveButtonTitle:reportTitle
                                                  onDestructiveButton:^(void)
                                  {
#if 0 // TODO
                                      [[VObjectManager sharedManager] flagConversation:self.conversation
                                                                      successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
                                       {
                                           UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ReportedTitle", @"")
                                                                                                  message:NSLocalizedString(@"ReportUserMessage", @"")
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                                                        otherButtonTitles:nil];
                                           [alert show];
                                           
                                       }
                                                                         failBlock:^(NSOperation* operation, NSError* error)
                                       {
                                           VLog(@"Failed to flag conversation %@", self.conversation);
                                           
                                           UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WereSorry", @"")
                                                                                                  message:NSLocalizedString(@"ErrorOccured", @"")
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                                                        otherButtonTitles:nil];
                                           [alert show];
                                       }];
#endif
                                  }
                                           otherButtonTitlesAndBlocks:nil];
    
    [actionSheet showInView:self.view];
}

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setOtherUser:(VUser *)otherUser
{
    _otherUser = otherUser;
    ((VMessageViewController*)self.conversationTableViewController).otherUser = otherUser;
    if ([self isViewLoaded])
    {
        [self addBackgroundImage];
    }
}

- (void)addBackgroundImage
{
    UIImage *defaultBackgroundImage = [[[VThemeManager sharedThemeManager] themedBackgroundImageForDevice] applyExtraLightEffect];
    
    if (self.otherUser)
    {
        [self.backgroundImageView setExtraLightBlurredImageWithURL:[NSURL URLWithString:self.otherUser.pictureUrl]
                                                  placeholderImage:defaultBackgroundImage];
    }
    else
    {
        self.backgroundImageView.image = defaultBackgroundImage;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // TODO: do we really need this?
#if 0
    //Be sure to delete the conversation if we've come to create a new conversation and stopped
    if (![[self.conversation messages] count])
    {
        NSManagedObjectContext* context =   self.conversation.managedObjectContext;
        [context deleteObject:self.conversation];
        [context saveToPersistentStore:nil];
        
        //Delete the evidence!
        ((VMessageViewController*)self.conversationTableViewController).conversation = nil;
        self.conversation = nil;
    }
#endif
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UITableViewController *)conversationTableViewController
{
    if (_conversationTableViewController == nil)
    {
        _conversationTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"messages"];
    }
    
    return _conversationTableViewController;
}

- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar didComposeWithText:(NSString *)text mediaURL:(NSURL *)mediaURL
{
#if 0 // TODO
    MBProgressHUD*  progressHUD =   [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHUD.labelText = NSLocalizedString(@"JustAMoment", @"");
    progressHUD.detailsLabelText = NSLocalizedString(@"PublishUpload", @"");
    
    __block NSNumber* oldID = self.conversation.remoteId;
    
    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        if (![oldID isEqualToValue:self.conversation.remoteId])
        {
            //If the ID on the conversation changes we need to refresh the fetch controller with the new ID.
            //This happens because we do not have the remote ID for the conversation until the first message is sent
            [((VMessageViewController*)self.conversationTableViewController) refreshFetchController];
        }
        [progressHUD hide:YES];
    };
    
    [[VObjectManager sharedManager] sendMessageToConversation:self.conversation
                                                     withText:text
                                                     mediaURL:mediaURL
                                                 successBlock:success
                                                    failBlock:^(NSOperation* operation, NSError* error)
     {
         VLog(@"Failed in creating message with error: %@", error);
         [progressHUD hide:YES];
         
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UploadError", @"")
                                                         message: NSLocalizedString(@"UploadErrorBody", @"")
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                               otherButtonTitles:nil];
         [alert show];
     }];
#endif
}

@end
