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
#import "VUserTaggingTextStorage.h"
#import "MBProgressHUD.h"
#import "VLaunchScreenProvider.h"
#import "VDependencyManager+VAccessoryScreens.h"
#import "VDependencyManager+VNavigationItem.h"
#import "VDependencyManager+VTracking.h"
#import "UIViewController+VAccessoryScreens.h"
#import "victorious-Swift.h"
#import "VUnreadMessageCountCoordinator.h"

static const NSUInteger kCharacterLimit = 1024;

@interface VConversationContainerViewController () <VAccessoryNavigationSource>

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;

@end

@implementation VConversationContainerViewController

@synthesize innerViewController = _innerViewController;

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VConversationContainerViewController *messageViewController = (VConversationContainerViewController *)[[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:kMessageContainerID];
    messageViewController.dependencyManager = dependencyManager;
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
    if ( [self.navigationController.viewControllers containsObject:self] )
    
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
    [self.dependencyManager addAccessoryScreensToNavigationItem:self.navigationItem fromViewController:self];
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
    NSString *blockTitle = NSLocalizedString(@"BlockInappropriate", @"Comment block inappropriate button");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:blockTitle
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *action)
                                {
                                    [self blockUser];
                                }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel button")
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)setConversation:(VConversation *)conversation
{
    _conversation = conversation;
    ((VConversationViewController *)self.innerViewController).conversation = conversation;
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
        NSURL *pictureURL = [self.conversation.user pictureURLOfMinimumSize:self.backgroundImageView.frame.size];
        [self.backgroundImageView applyExtraLightBlurAndAnimateImageWithURLToVisible:pictureURL];
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
    
    if ( [self.innerViewController isKindOfClass:[VConversationViewController class]] )
    {
        [(VConversationViewController *)self.innerViewController setMessageCountCoordinator:messageCountCoordinator];
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

- (VConversationViewController *)innerViewController
{
    if (_innerViewController == nil)
    {
        VConversationViewController *messageViewController = [VConversationViewController newWithDependencyManager:self.dependencyManager];
        messageViewController.messageCountCoordinator = self.messageCountCoordinator;
        _innerViewController = messageViewController;
    }
    
    return _innerViewController;
}

- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar didComposeWithText:(NSString *)text publishParameters:(VPublishParameters *)publishParameters
{
    if ( [VCurrentUser user] == nil )
    {
        return;
    }
    
    [self sendMessageWithText:text publishParameters:publishParameters inConversation:self.conversation completion:^
     {
         [[self innerViewController] fetchNewMessage];
     }];
    
    [keyboardBar clearKeyboardBar];
}

#pragma mark - Keyboard Delegate

- (void)setKeyboardBarHeight:(CGFloat)keyboardBarHeight
{
    [super setKeyboardBarHeight:keyboardBarHeight];
    
    // Inset our focus area because of the keyboard bar
    UIEdgeInsets focusAreaInsets = UIEdgeInsetsMake(0, 0, keyboardBarHeight, 0);
    [(VConversationViewController *)self.innerViewController setFocusAreaInset:focusAreaInsets];
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
    return YES;
}

@end
