//
//  VInboxContainerViewController.m
//  victorious
//
//  Created by Will Long on 5/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIStoryboard+VMainStoryboard.h"
#import "VAuthorizationViewControllerFactory.h"
#import "VInboxContainerViewController.h"
#import "VInboxViewController.h"
#import "VObjectManager.h"
#import "VRootViewController.h"
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

@end

@implementation VInboxContainerViewController

#pragma mark - Initializers

+ (instancetype)inboxContainer
{
    return [[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:kInboxContainerID];
}

#pragma mark VHasManagedDependencies conforming initializer

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    return [self inboxContainer];
}

#pragma mark -

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

@end
