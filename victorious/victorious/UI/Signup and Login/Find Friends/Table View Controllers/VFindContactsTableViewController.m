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

@import AddressBook;

@interface VFindContactsTableViewController ()

@property (nonatomic) ABAddressBookRef addressBook;

@end

@implementation VFindContactsTableViewController

- (void)dealloc
{
    if (_addressBook)
    {
        CFRelease(_addressBook); _addressBook = NULL;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setConnectPromptLabelText:NSLocalizedString(@"FindContacts", @"")];
    [self.tableView setSafetyInfoLabelText:NSLocalizedString(@"ContactsSafety", @"")];
    [self.tableView.connectButton setTitle:NSLocalizedString(@"Access Your Contacts", @"") forState:UIControlStateNormal];
}

- (void)setAddressBook:(ABAddressBookRef)addressBook
{
    if (_addressBook)
    {
        CFRelease(_addressBook);
    }
    _addressBook = addressBook ? CFRetain(addressBook) : NULL;
}

- (void)connectToSocialNetworkWithPossibleUserInteraction:(BOOL)userInteraction completion:(void (^)(BOOL, NSError *))completionBlock
{
    ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
    
    switch (authStatus)
    {
        case kABAuthorizationStatusAuthorized:
        {
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            if (addressBook)
            {
                self.addressBook = addressBook;
                CFRelease(addressBook);
                
                if ( self.addressBook != nil )
                {
                    NSArray *contacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(self.addressBook);
                    NSDictionary *params = @{ VTrackingKeyCount : @(contacts.count) };
                    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidImportDeviceContacts parameters:params];
                }
                
                if (completionBlock)
                {
                    completionBlock(YES, nil);
                }
                
            }
            else if (completionBlock)
            {
                completionBlock(NO, nil);
            }
            break;
        }
            
        case kABAuthorizationStatusDenied:
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
                                                      cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                      otherButtonTitles:nil];
                [alert show];
            }
            break;
        }
        case kABAuthorizationStatusRestricted:
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
                                                      cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                      otherButtonTitles:nil];
                [alert show];
            }
            break;
        }
            
        case kABAuthorizationStatusNotDetermined:
        {
            if (userInteraction)
            {
                ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
                ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                {
                    dispatch_async(dispatch_get_main_queue(), ^(void)
                    {
                        if (granted && addressBook)
                        {
                            self.addressBook = addressBook;
                            if (completionBlock)
                            {
                                completionBlock(YES, nil);
                            }
                        }
                        else if (completionBlock)
                        {
                            completionBlock(NO, nil);
                        }
                        
                        if (addressBook)
                        {
                            CFRelease(addressBook);
                        }
                    });
                });
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
    if (!self.addressBook)
    {
        completionBlock(nil, nil);
        return;
    }
    
    NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(self.addressBook);
    NSMutableArray *allEmailAddresses = [[NSMutableArray alloc] initWithCapacity:allContacts.count];
    
    for (NSUInteger i = 0; i < [allContacts count]; i++)
    {
        ABRecordRef person = (__bridge ABRecordRef)allContacts[i];
        ABMultiValueRef emailAddresses = ABRecordCopyValue(person, kABPersonEmailProperty);
        for (CFIndex j = 0; j < ABMultiValueGetCount(emailAddresses); j++)
        {
            NSString *emailAddress = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailAddresses, j);
            [allEmailAddresses addObject:emailAddress];
        }
        
        CFRelease(emailAddresses);
    }
    
    if (allEmailAddresses.count)
    {
        [[VObjectManager sharedManager] findFriendsByEmails:allEmailAddresses
                                           withSuccessBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
        {
            completionBlock(resultObjects, nil);
        }
                                                  failBlock:^(NSOperation *operation, NSError *error)
        {
            completionBlock(nil, error);
        }];
    }
    else
    {
        completionBlock(@[], nil);
    }
}

- (NSString *)headerTextForNewFriendsSection
{
    return NSLocalizedString(@"AddressBookFollowingSectionHeader", @"");
}

@end
