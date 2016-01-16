//
//  VMessageSubViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIImage+ImageEffects.h"
#import "UIImageView+Blurring.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "VConversationContainerViewController.h"
#import "VConversationViewController.h"
#import "VConversation.h"
#import "VUser.h"
#import "VUserTaggingTextStorage.h"
#import "MBProgressHUD.h"
#import "VLaunchScreenProvider.h"
#import "VDependencyManager+VAccessoryScreens.h"
#import "VDependencyManager+VNavigationItem.h"
#import "VDependencyManager+VTracking.h"
#import "UIViewController+VAccessoryScreens.h"
#import "victorious-Swift.h"

static const NSUInteger kCharacterLimit = 1024;

@interface VConversationContainerViewController () <VAccessoryNavigationSource>

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, readonly) BOOL canFlagConversation;

@end

@implementation VConversationContainerViewController

@synthesize conversationTableViewController = _conversationTableViewController;

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VConversationContainerViewController *messageViewController = (VConversationContainerViewController *)[[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:kMessageContainerID];
    messageViewController.dependencyManager = dependencyManager;
    return messageViewController;
}

+ (instancetype)messageViewControllerForConversation:(VConversation *)conversation dependencyManager:(VDependencyManager *)dependencyManager
{
    VConversationContainerViewController *messageViewController = (VConversationContainerViewController *)[[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:kMessageContainerID];
    messageViewController.dependencyManager = dependencyManager;
    messageViewController.conversation = conversation;
    return messageViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.keyboardBarViewController.shouldAutoClearOnCompose = NO;
    self.keyboardBarViewController.hideAccessoryBar = YES;
    self.keyboardBarViewController.textStorage.disableSearching = YES;
    self.keyboardBarViewController.characterLimit = kCharacterLimit;
    
    [self addBackgroundImage];
    [self hideKeyboardBarIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.dependencyManager trackViewWillAppear:self];
    
    [self setEdgesForExtendedLayout:UIRectEdgeAll];
    [self updateTitle];
    [self.dependencyManager configureNavigationItem:self.navigationItem];
    [self v_addAccessoryScreensWithDependencyManager:self.dependencyManager];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.dependencyManager trackViewWillDisappear:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self v_addBadgingToAccessoryScreensWithDependencyManager:self.dependencyManager];
}

- (void)updateTitle
{
    self.navigationItem.title = self.conversation.user.name;
}

- (void)showMoreOptions
{
    NSDictionary *params = @{ VTrackingKeyContext : VTrackingValueMessage };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectMoreActions parameters:params];
    
    // This is the only option available as of now
    [self showOptions];
}

- (void)showOptions
{
    NSString *reportTitle = NSLocalizedString(@"ReportInappropriate", @"Comment report inappropriate button");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:reportTitle
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *action)
                                {
                                    [self flagConversation];
                                }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CancelButton", @"Cancel button")
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)canFlagConversation
{
    id mostRecentMessage = self.conversation.messages.lastObject;
    return [mostRecentMessage isKindOfClass:[VMessage class]] && mostRecentMessage != nil;
}

- (void)flagConversation
{
    if ( !self.canFlagConversation )
    {
        return;
    }
    
    VMessage *mostRecentMessage = (VMessage *)self.conversation.messages.lastObject;
    NSInteger conversationID = self.conversation.remoteId.integerValue;
    NSInteger mostRecentMessageID = mostRecentMessage.remoteId.integerValue;
    FlagConversationOperation *operation = [[FlagConversationOperation alloc] initWithConversationID:conversationID
                                                                                 mostRecentMessageID:mostRecentMessageID];
    [operation queueOn:operation.defaultQueue completionBlock:^(NSError *_Nullable error)
     {
         if ( error != nil )
         {
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ReportedTitle", @"")
                                                                                      message:NSLocalizedString(@"ReportUserMessage", @"")
                                                                               preferredStyle:UIAlertControllerStyleAlert];
             [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                                 style:UIAlertActionStyleCancel
                                                               handler:nil]];
             [self presentViewController:alertController animated:YES completion:nil];
         }
         else
         {
             VLog(@"Failed to flag conversation %@", self.conversation);
             
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"WereSorry", @"")
                                                                                      message:NSLocalizedString(@"ErrorOccured", @"")
                                                                               preferredStyle:UIAlertControllerStyleAlert];
             [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                                 style:UIAlertActionStyleCancel
                                                               handler:nil]];
             [self presentViewController:alertController animated:YES completion:nil];
         }
     }];
}

- (void)setConversation:(VConversation *)conversation
{
    _conversation = conversation;
    ((VConversationViewController *)self.conversationTableViewController).conversation = conversation;
    if ([self isViewLoaded])
    {
        [self addBackgroundImage];
        [self hideKeyboardBarIfNeeded];
    }
    [self updateTitle];
}

- (void)hideKeyboardBarIfNeeded
{
    if (self.conversation.user.isDirectMessagingDisabled.boolValue)
    {
        self.keyboardBarViewController.view.hidden = YES;
    }
}

- (void)addBackgroundImage
{
    if ( self.conversation.user != nil )
    {
        [self.backgroundImageView applyExtraLightBlurAndAnimateImageWithURLToVisible:[NSURL URLWithString:self.conversation.user.pictureUrl]];
    }
    else
    {
        UIImage *launchScreenImage = [VLaunchScreenProvider screenshotOfLaunchScreenAtSize:self.view.bounds.size];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
        {
            UIImage *defaultBackgroundImage = [launchScreenImage applyExtraLightEffect];
            dispatch_async(dispatch_get_main_queue(), ^
            {
                self.backgroundImageView.image = defaultBackgroundImage;
            });
        });
    }
}

- (void)setMessageCountCoordinator:(VUnreadMessageCountCoordinator *)messageCountCoordinator
{
    _messageCountCoordinator = messageCountCoordinator;
    
    if ( [self.conversationTableViewController isKindOfClass:[VConversationViewController class]] )
    {
        [(VConversationViewController *)self.conversationTableViewController setMessageCountCoordinator:messageCountCoordinator];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (BOOL)v_prefersNavigationBarHidden
{
    return NO;
}

- (UITableViewController *)conversationTableViewController
{
    if (_conversationTableViewController == nil)
    {
        VConversationViewController *messageViewController = [VConversationViewController newWithDependencyManager:self.dependencyManager];
        messageViewController.messageCountCoordinator = self.messageCountCoordinator;
        _conversationTableViewController = messageViewController;
    }
    
    return _conversationTableViewController;
}

- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar didComposeWithText:(NSString *)text publishParameters:(VPublishParameters *)publishParameters
{
    VUser *currentUser = [VCurrentUser user];
    if ( currentUser == nil )
    {
        return;
    }
    
    [self sendMessageWithText:text
               inConversation:self.conversation
                   completion:^(NSError *_Nullable error)
     {
         if ( error == nil )
         {
             VConversationViewController* conversationVC = (VConversationViewController *)self.conversationTableViewController;
             [conversationVC.dataSource loadMessagesWithPageType:VPageTypeCheckNew completion:nil];
         }
    }];
    
    [keyboardBar.textView resignFirstResponder];
    [keyboardBar clearKeyboardBar];
}

#pragma mark - Keyboard Delegate

- (void)setKeyboardBarHeight:(CGFloat)keyboardBarHeight
{
    [super setKeyboardBarHeight:keyboardBarHeight];
    
    // Inset our focus area because of the keyboard bar
    UIEdgeInsets focusAreaInsets = UIEdgeInsetsMake(0, 0, keyboardBarHeight, 0);
    [(VConversationViewController *)self.conversationTableViewController setFocusAreaInset:focusAreaInsets];
}

#pragma mark - Authorization

- (BOOL)requiresAuthorization
{
    return YES;
}

- (VAuthorizationContext)authorizationContext
{
    return VAuthorizationContextInbox;
}

#pragma mark - VAccessoryNavigationSource

- (BOOL)shouldNavigateWithAccessoryMenuItem:(VNavigationMenuItem *)menuItem
{
    if ( [menuItem.identifier isEqualToString:VDependencyManagerAccessoryItemMore] )
    {
        [self showMoreOptions];
        return NO;
    }
    return YES;
}

- (BOOL)shouldDisplayAccessoryMenuItem:(VNavigationMenuItem *)menuItem fromSource:(UIViewController *)source
{
    if ( [menuItem.identifier isEqualToString:VDependencyManagerAccessoryItemMore] )
    {
        return self.canFlagConversation;
    }
    return YES;
}

@end
