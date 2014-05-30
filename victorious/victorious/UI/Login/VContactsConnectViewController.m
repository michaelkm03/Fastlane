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

@interface VContactsConnectViewController ()
@end

@implementation VContactsConnectViewController

- (IBAction)connect:(id)sender
{
    ABAddressBookRef        addressBook;

    switch (ABAddressBookGetAuthorizationStatus())
    {
        case kABAuthorizationStatusAuthorized:
        {
            addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            [self getEmailAddresses:addressBook];
            if (NULL != addressBook)
                CFRelease(addressBook);
            break;
        }
            
        case kABAuthorizationStatusDenied:
        {
            [self showAccessAlert];
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
                });
            });
        }
            
        case kABAuthorizationStatusRestricted:
        {
            [self showAccessAlert];
            break;
        }
    }
}

- (void)getEmailAddresses:(ABAddressBookRef)addressBook
{
    NSMutableArray*     allEmailAddresses = [[NSMutableArray alloc] init];
    NSArray*            allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);

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
    
    //  API call of email addresses to server
    //  if success, performSegue to list viewcontroller
    [self performSegueWithIdentifier:@"toContactsList" sender:self];
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toContactsList"])
    {
        
    }
}

@end
