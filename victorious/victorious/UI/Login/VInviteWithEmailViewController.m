//
//  VInviteWithEmailViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VInviteWithEmailViewController.h"

@import AddressBookUI;

@interface VInviteWithEmailViewController () <ABPeoplePickerNavigationControllerDelegate>
@property (nonatomic, strong)   NSMutableArray*     friends;
@property (nonatomic, strong)   NSMutableArray*     emails;
@property (nonatomic, strong)   NSMutableArray*     images;
@end

@implementation VInviteWithEmailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.friends = [[NSMutableArray alloc] init];
    
    UIBarButtonItem*    addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                  target:self
                                                                                  action:@selector(addFriend:)];
    
    UIBarButtonItem*    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                   target:self
                                                                                   action:@selector(done:)];
    self.navigationItem.rightBarButtonItems = @[addButton, doneButton];
}

- (IBAction)addFriend:(id)sender
{
    ABPeoplePickerNavigationController* picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.displayedProperties = @[@(kABPersonEmailProperty)];
    picker.peoplePickerDelegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)done:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
    for (CFIndex i = 0; i < ABMultiValueGetCount(emails); i++)
    {
        NSString *label = (NSString *)CFBridgingRelease(ABMultiValueCopyLabelAtIndex(emails, i));
        if ([label isEqualToString:(NSString *)kABHomeLabel])
        {
            NSString *emailAddress = (NSString *)CFBridgingRelease(ABMultiValueCopyValueAtIndex(emails, i));
            [self.emails addObject:emailAddress];
            break;
        }
    }
    
    [self.friends addObject:(NSString *)CFBridgingRelease(ABRecordCopyCompositeName(person))];
    
    if (ABPersonHasImageData(person))
    {
        NSData* imageData = (NSData*)CFBridgingRelease(ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail));
        [self.images addObject:[UIImage imageWithData:imageData]];
    }
    else
    {
        [self.images addObject:[UIImage imageNamed:@"profile_thumb"]];
    }
    
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return YES;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
