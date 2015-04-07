//
//  VInboxContainerViewController.m
//  victorious
//
//  Created by Will Long on 5/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSURL+VPathHelper.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "VAuthorizedAction.h"
#import "VConversation.h"
#import "VDependencyManager+VObjectManager.h"
#import "VInboxContainerViewController.h"
#import "VInboxViewController.h"
#import "VMessageContainerViewController.h"
#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Pagination.h"
#import "VSettingManager.h"
#import "VUnreadMessageCountCoordinator.h"
#import "VConstants.h"
#import "VInboxDeepLinkHandler.h"

@interface VInboxContainerViewController ()

@property (weak, nonatomic) IBOutlet UIView *noMessagesView;
@property (weak, nonatomic) IBOutlet UILabel *noMessagesTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noMessagesMessageLabel;
@property (weak, nonatomic, readwrite) VInboxViewController *inboxViewController;
@property (strong, nonatomic) VUnreadMessageCountCoordinator *messageCountCoordinator;
@property (strong, nonatomic) VDependencyManager *dependencyManager;
@property (nonatomic) NSInteger badgeNumber;
@property (copy, nonatomic) VNavigationMenuItemBadgeNumberUpdateBlock badgeNumberUpdateBlock;

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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profileCompose"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self.inboxViewController
                                                                             action:@selector(userSearchAction:)];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
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
        inboxViewController.dependencyManager = self.dependencyManager;
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

#pragma mark - VNavigationDestination

- (VAuthorizationContext)authorizationContext
{
    return VAuthorizationContextInbox;
}

#pragma mark - VDeeplinkSupporter methods

- (id<VDeeplinkHandler>)deeplinkHandler
{
    return [[VInboxDeepLinkHandler alloc] initWithDependencyManager:self.dependencyManager
                                       inboxContainerViewController:self];
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
