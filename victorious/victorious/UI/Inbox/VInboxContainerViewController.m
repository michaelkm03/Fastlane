//
//  VInboxContainerViewController.m
//  victorious
//
//  Created by Will Long on 5/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIStoryboard+VMainStoryboard.h"
#import "VAuthorizationViewControllerFactory.h"
#import "VDeeplinkManager.h"
#import "VDependencyManager+VObjectManager.h"
#import "VInboxContainerViewController.h"
#import "VInboxViewController.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Pagination.h"
#import "VRootViewController.h"
#import "VUnreadMessageCountCoordinator.h"
#import "VConstants.h"
#import "UIViewController+VNavMenu.h"

typedef enum {
    vFilterBy_Messages = 0,
    vFilterBy_Notifications = 1

} vFilterBy;

@interface VInboxContainerViewController () <VNavigationHeaderDelegate>

@property (weak, nonatomic) IBOutlet UIView *noMessagesView;
@property (weak, nonatomic) IBOutlet UILabel *noMessagesTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noMessagesMessageLabel;
@property (weak, nonatomic) VInboxViewController *inboxViewController;
@property (strong, nonatomic) VUnreadMessageCountCoordinator *messageCountCoordinator;
@property (strong, nonatomic) VDependencyManager *dependencyManager;
@property (nonatomic) NSInteger badgeNumber;
@property (copy, nonatomic) VNavigationMenuItemBadgeNumberUpdateBlock badgeNumberUpdateBlock;

@end

static char kKVOContext;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inboxMessageNotification:) name:VDeeplinkManagerInboxMessageNotification object:nil];
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
    [self.filterControls setSelectedSegmentIndex:vFilterBy_Messages];
    self.headerView.hidden = YES;
    
    self.inboxViewController = self.childViewControllers.firstObject;
    
    [self v_addNewNavHeaderWithTitles:nil];
    self.navHeaderView.delegate = self;
    [self.navHeaderView setRightButtonImage:[UIImage imageNamed:@"profileCompose"]
                                 withAction:@selector(userSearchAction:)
                                   onTarget:self.inboxViewController];
}

- (IBAction)changedFilterControls:(id)sender
{
    [[VInboxViewController inboxViewController] toggleFilterControl:self.filterControls.selectedSegmentIndex];
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
        [self.dependencyManager.objectManager refreshConversationListWithSuccessBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
        {
            [self.messageCountCoordinator updateUnreadMessageCount];
        } failBlock:nil];
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
