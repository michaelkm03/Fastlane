//
//  VInboxContainerViewController.m
//  victorious
//
//  Created by Will Long on 5/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSURL+VPathHelper.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "VAuthorizationViewControllerFactory.h"
#import "VConversation.h"
#import "VDependencyManager+VObjectManager.h"
#import "VInboxContainerViewController.h"
#import "VInboxViewController.h"
#import "VMessageContainerViewController.h"
#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Pagination.h"
#import "VRootViewController.h"
#import "VSettingManager.h"
#import "VUnreadMessageCountCoordinator.h"
#import "VConstants.h"
#import "UIViewController+VNavMenu.h"

@interface VInboxContainerViewController () <VNavigationHeaderDelegate>

@property (weak, nonatomic) IBOutlet UIView *noMessagesView;
@property (weak, nonatomic) IBOutlet UILabel *noMessagesTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noMessagesMessageLabel;
@property (weak, nonatomic) VInboxViewController *inboxViewController;
@property (strong, nonatomic) VUnreadMessageCountCoordinator *messageCountCoordinator;
@property (strong, nonatomic) VDependencyManager *dependencyManager;
@property (nonatomic) NSInteger badgeNumber;
@property (copy, nonatomic) VNavigationMenuItemBadgeNumberUpdateBlock badgeNumberUpdateBlock;
@property (strong, nonatomic) VUser *userConversationToDisplayOnNextAppearance;

@end

static char kKVOContext;

NSString * const VInboxContainerViewControllerDeeplinkHostComponent = @"inbox";
NSString * const VInboxContainerViewControllerInboxPushReceivedNotification = @"VInboxContainerViewControllerInboxPushReceivedNotification";

@implementation VInboxContainerViewController

#pragma mark - Initializers

+ (instancetype)inboxContainer
{
    return [[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:kInboxContainerID];
}

#pragma mark VHasManagedDependencies conforming initializer

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VInboxContainerViewController *container = [self inboxContainer];
    container.dependencyManager = dependencyManager;
    container.messageCountCoordinator = [[VUnreadMessageCountCoordinator alloc] initWithObjectManager:[dependencyManager objectManager]];
    return container;
}

#pragma mark -

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedInChanged:) name:kLoggedInChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inboxMessageNotification:) name:VInboxContainerViewControllerInboxPushReceivedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc
{
    self.messageCountCoordinator = nil; // calling property setter to remove KVO
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = NSLocalizedString(@"Inbox", nil);
    
    self.inboxViewController = self.childViewControllers.firstObject;
    
    [self v_addNewNavHeaderWithTitles:nil];
    self.navHeaderView.delegate = self;
    [self.navHeaderView setRightButtonImage:[UIImage imageNamed:@"profileCompose"]
                                 withAction:@selector(userSearchAction:)
                                   onTarget:self.inboxViewController];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ( self.userConversationToDisplayOnNextAppearance != nil )
    {
        [self.navigationController popToViewController:self animated:NO];
        [self.inboxViewController displayConversationForUser:self.userConversationToDisplayOnNextAppearance];
        self.userConversationToDisplayOnNextAppearance = nil;
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    BOOL isTemplateC = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
    return isTemplateC ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}

- (void)setMessageCountCoordinator:(VUnreadMessageCountCoordinator *)messageCountCoordinator
{
    if (_messageCountCoordinator)
    {
        [_messageCountCoordinator removeObserver:self forKeyPath:NSStringFromSelector(@selector(unreadMessageCount))];
    }
    _messageCountCoordinator = messageCountCoordinator;
    
    if (messageCountCoordinator)
    {
        [messageCountCoordinator addObserver:self forKeyPath:NSStringFromSelector(@selector(unreadMessageCount)) options:NSKeyValueObservingOptionNew context:&kKVOContext];
        
        if ( [self.dependencyManager.objectManager mainUserLoggedIn] )
        {
            [messageCountCoordinator updateUnreadMessageCount];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    VInboxViewController *inboxViewController = segue.destinationViewController;

    if ( [inboxViewController isKindOfClass:[VInboxViewController class]] )
    {
        inboxViewController.messageCountCoordinator = self.messageCountCoordinator;
    }
}

- (void)setBadgeNumber:(NSInteger)badgeNumber
{
    if ( badgeNumber == _badgeNumber )
    {
        return;
    }
    _badgeNumber = badgeNumber;
    
    if ( self.badgeNumberUpdateBlock != nil )
    {
        self.badgeNumberUpdateBlock(self.badgeNumber);
    }
}

#pragma mark - VNavigationDestination methods

- (BOOL)shouldNavigateWithAlternateDestination:(UIViewController *__autoreleasing *)alternateViewController
{
    UIViewController *authorizationViewController = [VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:self.dependencyManager.objectManager];
    if (authorizationViewController)
    {
        [[VRootViewController rootViewController] presentViewController:authorizationViewController animated:YES completion:nil];
        return NO;
    }
    return YES;
}

#pragma mark - VDeeplinkHandler methods

- (BOOL)displayContentForDeeplinkURL:(NSURL *)url completion:(VDeeplinkHandlerCompletionBlock)completion
{
    if ( ![self.dependencyManager.objectManager authorized] )
    {
        return NO;
    }
    
    if ( [url.host isEqualToString:VInboxContainerViewControllerDeeplinkHostComponent] )
    {
        NSInteger conversationID = [[url firstNonSlashPathComponent] integerValue];
        if ( conversationID != 0 )
        {
            [[VObjectManager sharedManager] conversationByID:@(conversationID)
                                                successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
            {
                VConversation *conversation = (VConversation *)[resultObjects firstObject];
                if ( conversation == nil )
                {
                    completion(nil);
                }
                else
                {
                    self.userConversationToDisplayOnNextAppearance = conversation.user;
                    completion(self);
                }
            }
                                                   failBlock:^(NSOperation *operation, NSError *error)
            {
                VLog(@"Failed to load conversation with error: %@", [error localizedDescription]);
                completion(nil);
            }];
            return YES;
        }
    }
    return NO;
}

#pragma mark - NSNotification handlers

- (void)loggedInChanged:(NSNotification *)notification
{
    if ( self.dependencyManager.objectManager.mainUserLoggedIn )
    {
        [self.messageCountCoordinator updateUnreadMessageCount];
    }
    else
    {
        self.badgeNumber = 0;
    }
}

- (void)inboxMessageNotification:(NSNotification *)notification
{
    if ( self.dependencyManager.objectManager.mainUserLoggedIn )
    {
        [self.dependencyManager.objectManager loadConversationListWithPageType:VPageTypeFirst
                                                                  successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
        {
            [self.messageCountCoordinator updateUnreadMessageCount];
        } failBlock:nil];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if ( self.dependencyManager.objectManager.mainUserLoggedIn )
    {
        [self.messageCountCoordinator updateUnreadMessageCount];
    }
}

#pragma mark - Key-Value Observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( context != &kKVOContext )
    {
        return;
    }
    
    if ( object == self.messageCountCoordinator && [keyPath isEqualToString:NSStringFromSelector(@selector(unreadMessageCount))] )
    {
        NSNumber *newUnreadCount = change[NSKeyValueChangeNewKey];
        
        if ( [newUnreadCount isKindOfClass:[NSNumber class]] )
        {
            self.badgeNumber = [newUnreadCount integerValue];
        }
    }
}

@end
