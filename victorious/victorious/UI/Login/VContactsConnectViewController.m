//
//  VContactsConnectViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AddressBook;

#import "VContactsConnectViewController.h"
#import "MBProgressHUD.h"
#import "VObjectManager+Users.h"
#import "VInviteContactsViewController.h"

#import <CommonCrypto/CommonHMAC.h>

@interface VContactsConnectViewController ()
@end

@implementation VContactsConnectViewController

- (IBAction)connect:(id)sender
{
    self.connectButton.userInteractionEnabled = NO;

    ABAddressBookRef        addressBook;

    switch (ABAddressBookGetAuthorizationStatus())
    {
        case kABAuthorizationStatusAuthorized:
        {
            addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            [self getEmailAddresses:addressBook];
            if (NULL != addressBook)
                CFRelease(addressBook);
            self.connectButton.userInteractionEnabled = YES;
            break;
        }
            
        case kABAuthorizationStatusDenied:
        {
            [self showAccessAlert];
            self.connectButton.userInteractionEnabled = YES;
            break;
        }
            
        case kABAuthorizationStatusNotDetermined:
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];

            addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted)
                        [self getEmailAddresses:addressBook];
                    else
                        [self showAccessAlert];
                
                    if (NULL != addressBook)
                        CFRelease(addressBook);
                
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    self.connectButton.userInteractionEnabled = YES;
                });
            });
        }
            
        case kABAuthorizationStatusRestricted:
        {
            [self showAccessAlert];
            self.connectButton.userInteractionEnabled = YES;
            break;
        }
    }
}

- (void)getEmailAddresses:(ABAddressBookRef)addressBook
{
    NSArray*            allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSMutableArray*     allEmailAddresses = [[NSMutableArray alloc] initWithCapacity:allContacts.count];

    for (CFIndex i = 0; i < [allContacts count]; i++)
    {
        ABRecordRef        person = (__bridge ABRecordRef)allContacts[i];
        ABMultiValueRef    emailAddresses = ABRecordCopyValue(person, kABPersonEmailProperty);
        for (CFIndex j = 0; j < ABMultiValueGetCount(emailAddresses); j++)
        {
            NSString*  emailAddress = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailAddresses, j);
            [allEmailAddresses addObject:emailAddress];
        }
        
        CFRelease(emailAddresses);
    }
    
    [[VObjectManager sharedManager] findFriendsByEmails:allEmailAddresses
                                       withSuccessBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
                                       {
                                           self.users = resultObjects;
                                           [self performSegueWithIdentifier:@"toContactsList" sender:self];
                                       }
                                              failBlock:^(NSOperation* operation, NSError* error)
                                              {
                                                  // Failure
                                              }];
}

- (void)showAccessAlert
{
    UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AccessContactsDenied", @"")
                                                           message:NSLocalizedString(@"CantReadEmailAddresses", @"")
                                                          delegate:nil
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
    [alert show];
}

- (NSString *)hashedString:(NSString *)string
{
    const   int8_t      kSaltLength =   8;

    uint8_t     salt[8];
    SecRandomCopyBytes(kSecRandomDefault, kSaltLength, salt);

    NSData*         input   =   [string dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData*  data    =   [NSMutableData dataWithLength:kSaltLength + input.length];
    [data appendBytes:salt length:8];
    [data appendData:input];
    
    uint8_t     digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, data.length, digest);
    
    for (int i = 0; i < 999; i++)
        CC_SHA256(digest, CC_SHA256_DIGEST_LENGTH, digest);
    
    NSMutableString*    output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < 8; i++)
        [output appendFormat:@"%02x", salt[i]];

    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return [NSString stringWithString:output];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toContactsList"])
    {
        VInviteContactsViewController*   contactsListViewController = (VInviteContactsViewController *)segue.destinationViewController;
        contactsListViewController.users = self.users;
    }
}

@end
