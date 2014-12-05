//
//  VInboxContainerViewController.m
//  victorious
//
//  Created by Will Long on 5/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIStoryboard+VMainStoryboard.h"
#import "VAuthorizationViewControllerFactory.h"
#import "VDependencyManager+VObjectManager.h"
#import "VInboxContainerViewController.h"
#import "VInboxViewController.h"
#import "VObjectManager+Login.h"
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
    container.messageCountCoordinator = [[VUnreadMessageCountCoordinator alloc] initWithObjectManager:[dependencyManager objectManager]];
    return container;
}

#pragma mark -

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedInChanged:) name:kLoggedInChangedNotification object:nil];
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
        [messageCountCoordinator updateUnreadMessageCount];
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

#pragma mark - VNavigationDestination methods

- (BOOL)shouldNavigateWithAlternateDestination:(UIViewController *__autoreleasing *)alternateViewController
{
    UIViewController *authorizationViewController = [VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]];
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
    [self.messageCountCoordinator updateUnreadMessageCount];
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
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[newUnreadCount integerValue]];
            });
        }
    }
}

@end
