//
//  VFindContactsTableViewController.m
//  victorious
//
//  Created by Josh Hinman on 6/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFindContactsTableViewController.h"
#import "VFindFriendsTableView.h"
#import "VObjectManager+Users.h"
#import "VPermission.h"
#import "VPermissionsTrackingHelper.h"
#import "victorious-swift.h"

@import Contacts;

@interface VFindContactsTableViewController ()

@property (nonatomic, strong) VPermissionsTrackingHelper *permissionTrackingHelper;

@end

@implementation VFindContactsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.permissionTrackingHelper = [[VPermissionsTrackingHelper alloc] init];
    [self.tableView setConnectPromptLabelText:NSLocalizedString(@"FindContacts", @"")];
    [self.tableView setSafetyInfoLabelText:NSLocalizedString(@"ContactsSafety", @"")];
    [self.tableView.connectButton setTitle:NSLocalizedString(@"Access Your Contacts", @"") forState:UIControlStateNormal];
}

- (void)connectToSocialNetworkWithPossibleUserInteraction:(BOOL)userInteraction completion:(void (^)(BOOL, NSError *))completionBlock
{
    CNAuthorizationStatus authorizationStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    switch (authorizationStatus)
    {
        case CNAuthorizationStatusAuthorized:
        {
            if (completionBlock)
            {
                completionBlock(YES, nil);
            }
            break;
        }
            
        case CNAuthorizationStatusDenied:
        {
            if (completionBlock)
            {
                completionBlock(NO, nil);
            }
            if (userInteraction)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:NSLocalizedString(@"AccessContactsDenied", @"")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                      otherButtonTitles:nil];
                [alert show];
            }
            break;
        }
        case CNAuthorizationStatusRestricted:
        {
            if (completionBlock)
            {
                completionBlock(NO, nil);
            }
            if (userInteraction)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:NSLocalizedString(@"AccessContactsRestricted", @"")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                      otherButtonTitles:nil];
                [alert show];
            }
            break;
        }
            
        case CNAuthorizationStatusNotDetermined:
        {
            if (userInteraction)
            {
                CNContactStore *store = [[CNContactStore alloc] init];
                [store requestAccessForEntityType:CNEntityTypeContacts
                                completionHandler:^(BOOL granted, NSError *_Nullable error)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^
                     {
                         NSString *permissionTrackingState = granted ? VTrackingValueAuthorized : VTrackingValueDenied;
                         [self.permissionTrackingHelper permissionsDidChange:VTrackingValueContactsDidAllow
                                                             permissionState:permissionTrackingState];
                         if (completionBlock != nil)
                         {
                             completionBlock(granted, nil);
                         }
                     });
                 }];
            }
            else if (completionBlock)
            {
                completionBlock(NO, nil);
            }
            break;
        }
    }
}

- (void)loadFriendsFromSocialNetworkWithCompletion:(void (^)(NSArray *, NSError *))completionBlock
{
    if (!completionBlock)
    {
        return;
    }

    CNContactStore *contactStore = [[CNContactStore alloc] init];
    NSError *error = nil;
    NSArray<CNContainer *> *containers = [contactStore containersMatchingPredicate:nil
                                                                             error:&error];
    NSMutableArray<CNContact *> *allContacts = [[NSMutableArray alloc] init];
    if (containers == nil)
    {
        [self trackFoundUsersCount:0];
    }
    else
    {
        for (CNContainer *container in containers)
        {
            NSPredicate *fetchPredicate = [CNContact predicateForContactsInContainerWithIdentifier:container.identifier];
            
            NSArray<CNContact *> *containerResults = [contactStore unifiedContactsMatchingPredicate:fetchPredicate
                                                                                        keysToFetch:@[CNContactEmailAddressesKey]
                                                                                              error:&error];
            [allContacts addObjectsFromArray:containerResults];
        }
        [self trackFoundUsersCount:allContacts.count];
    }
    
    NSMutableArray *allEmailAddresses = [[NSMutableArray alloc] init];
    for (CNContact *contact in allContacts)
    {
        for (CNLabeledValue *emailValue in contact.emailAddresses)
        {
            [allEmailAddresses addObject:emailValue.value];
        }
    }
    
    if (allEmailAddresses.count > 0)
    {
        FriendFindByEmailOperation *operation = [[FriendFindByEmailOperation alloc] initWithEmails:allEmailAddresses];
        [operation queueOn:RequestOperation.sharedQueue
           completionBlock:^(NSError *_Nullable error)
         {
             NSArray *results = operation.results;
             completionBlock(results, error);
         }];
    }
    else
    {
        completionBlock(@[], nil);
    }
}

- (void)trackFoundUsersCount:(NSUInteger)count
{
    NSDictionary *params = @{ VTrackingKeyCount : @(count) };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidImportDeviceContacts
                                       parameters:params];
}

- (NSString *)headerTextForNewFriendsSection
{
    return NSLocalizedString(@"AddressBookFollowingSectionHeader", @"");
}

@end
