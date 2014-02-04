//
//  VProfileViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileViewController.h"
#import "UIViewController+VSideMenuViewController.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+DirectMessaging.h"
#import "VProfileEditViewController.h"
#import "VMessageViewController.h"
#import "VUser.h"
#import "VThemeManager.h"
#import "VLoginViewController.h"

@interface VProfileViewController () <UIActionSheetDelegate>
@property   (nonatomic) VProfileUserID      userID;
@property   (nonatomic, strong) VUser*      profile;

@property (nonatomic, weak) IBOutlet UIImageView* backgroundImageView;

@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, weak) IBOutlet UILabel* taglineLabel;
@property (nonatomic, weak) IBOutlet UILabel* locationLabel;

@end

@implementation VProfileViewController

+ (instancetype)profileWithSelf
{
    UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VProfileViewController* profileViewController = (VProfileViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: @"profile"];
    
    profileViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Menu"]
                                                                                              style:UIBarButtonItemStylePlain
                                                                                             target:profileViewController
                                                                                             action:@selector(showMenu:)];
    profileViewController.userID = -1;
    return profileViewController;
}

+ (instancetype)profileWithUserID:(VProfileUserID)aUserID
{
    UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VProfileViewController* profileViewController = (VProfileViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: @"profile"];

    profileViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                                           target:profileViewController
                                                                                                           action:@selector(closeButtonAction:)];

    return profileViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ((-1 == self.userID) || (self.userID == [VObjectManager sharedManager].mainUser.remoteId.integerValue))
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                               target:self
                                                                                               action:@selector(editButtonAction:)];
        self.profile = [VObjectManager sharedManager].mainUser;
        [self setProfileData];
    }
    else
    {
        UIBarButtonItem* composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                       target:self
                                                                                       action:@selector(composeButtonAction:)];
        UIBarButtonItem* userActionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                          target:self
                                                                                          action:@selector(actionButtonAction:)];
        self.navigationItem.rightBarButtonItems = @[composeButton, userActionButton];

        [[VObjectManager sharedManager] fetchUser:@(self.userID)
                                 withSuccessBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
                                 {
                                     self.profile = [resultObjects firstObject];
                                     [self setProfileData];
                                 }
                                        failBlock:^(NSOperation* operation, NSError* error)
                                        {
                                            VLog("Profile failed to get User object");
                                        }];
    }
}

- (void)setProfileData
{
    //  Set background profile image
    NSURL*  imageURL    =   [NSURL URLWithString:self.profile.pictureUrl];
    [self.backgroundImageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"profile_full"]];
    
    // Set Profile data
    self.nameLabel.text = self.profile.name;
    self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.profile.username"];
    self.taglineLabel.text = [NSString stringWithFormat:@"“%@”",self.profile.tagline];
    self.taglineLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.profile.tagline"];
    self.locationLabel.text = self.profile.location;
    self.locationLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.profile.location"];

    self.navigationController.title = self.profile.shortName;
}

#pragma mark - Actions

- (IBAction)editButtonAction:(id)sender
{
    [self performSegueWithIdentifier:@"toEditProfile" sender:self];
}

-(IBAction)composeButtonAction:(id)sender
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }

    [self performSegueWithIdentifier:@"toComposeMessage" sender:self];
}

-(IBAction)actionButtonAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"CancelButton", @"")
                                               destructiveButtonTitle:NSLocalizedString(@"ReportInappropriate", @"")
                                                    otherButtonTitles:NSLocalizedString(@"BlockUser", @""),
                                  NSLocalizedString(@"CopyProfileURL", @""), nil];

    [actionSheet showFromBarButtonItem:sender animated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(int)buttonIndex
{
    if (buttonIndex == 0)
    {
        NSLog(@"Report Button Clicked");
    }
    else if (buttonIndex == 1)
    {
        NSLog(@"Block button 1 Clicked");
    }
    else if (buttonIndex == 2)
    {
        NSLog(@"Copy Profile Button 2 Clicked");
    }
    else if (buttonIndex == 3)
    {
        NSLog(@"Cancel Button Clicked");
    }
}

- (IBAction)showMenu:(id)sender
{
    [self.sideMenuViewController presentMenuViewController];
}

- (IBAction)closeButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toEditProfile"])
    {
        VProfileEditViewController* controller = (VProfileEditViewController *)segue.destinationViewController;
        controller.profile = self.profile;
    }
    else if ([segue.identifier isEqualToString:@"toComposeMessage"])
    {
        VMessageViewController *subview = (VMessageViewController *)segue.destinationViewController;
        subview.conversation = [[VObjectManager sharedManager] conversationWithUser:self.profile];
    }
}

@end
