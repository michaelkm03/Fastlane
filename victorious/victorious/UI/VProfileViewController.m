//
//  VProfileViewController.m
//  victorious
//
//  Created by Kevin Choi on 1/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileViewController.h"
#import "VMenuViewController.h"
#import "VMenuViewControllerTransition.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+DirectMessaging.h"
#import "VProfileEditViewController.h"
#import "VMessageSubViewController.h"
#import "VConversation.h"
#import "VUser.h"
#import "VThemeManager.h"
#import "VSimpleLoginViewController.h"

@interface VProfileViewController () <UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UIImageView* backgroundImageView;

@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, weak) IBOutlet UILabel* taglineLabel;
@property (nonatomic, weak) IBOutlet UILabel* locationLabel;

@property (nonatomic, readwrite, strong) VUser* profile;

@end

@implementation VProfileViewController

+ (VProfileViewController *)sharedProfileViewController
{
    static  VProfileViewController*   profileViewController;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        profileViewController = (VProfileViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: @"profile"];
    });
    
    return profileViewController;
}

+ (VProfileViewController *)sharedModalProfileViewController
{
    static  VProfileViewController*   profileViewController;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        profileViewController = (VProfileViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: @"profile"];
        profileViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Close"]
                                                                                                  style:UIBarButtonItemStylePlain
                                                                                                 target:profileViewController
                                                                                                 action:@selector(closeButtonAction:)];
    });

    return profileViewController;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ((-1 == self.userID) || (self.userID == [VObjectManager sharedManager].mainUser.remoteId.integerValue))
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                               target:self
                                                                                               action:@selector(editButtonPressed:)];
        self.profile = [VObjectManager sharedManager].mainUser;
        [self setProfileData];
    }
    else
    {
        // If the user is not logged in, create a compose button and user action button
        UIBarButtonItem* composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                       target:self
                                                                                       action:@selector(composeButtonPressed:)];
        UIBarButtonItem* userActionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                          target:self
                                                                                          action:@selector(userActionButtonPressed:)];

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

- (void)closeButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

-(IBAction)composeButtonPressed:(id)sender
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VSimpleLoginViewController sharedLoginViewController] animated:YES completion:NULL];
        return;
    }
    
    [self performSegueWithIdentifier:@"toComposeMessage" sender:self];
}

-(IBAction)userActionButtonPressed:(id)sender
{
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@""
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"CancelButton", @"")
                                              destructiveButtonTitle:NSLocalizedString(@"ReportInappropriate", @"")
                                                   otherButtonTitles:NSLocalizedString(@"BlockUser", @""),
                                 NSLocalizedString(@"CopyProfileURL", @""), nil];
    
    [popupQuery showFromBarButtonItem:sender animated:YES];
}

- (IBAction)editButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"toEditProfile" sender:self];
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toEditProfile"])
    {
        VProfileEditViewController* controller = (VProfileEditViewController *)segue.destinationViewController;
        controller.profile = self.profile;
    }
    else if ([segue.destinationViewController isKindOfClass:[VMenuViewController class]])
    {
        VMenuViewController *menuViewController = segue.destinationViewController;
        menuViewController.transitioningDelegate = (id <UIViewControllerTransitioningDelegate>)[VMenuViewControllerTransitionDelegate new];
        menuViewController.modalPresentationStyle = UIModalPresentationCustom;
    }
    else if ([segue.identifier isEqualToString:@"toComposeMessage"])
    {
        VMessageSubViewController *subview = (VMessageSubViewController *)segue.destinationViewController;
        subview.conversation = [[VObjectManager sharedManager] conversationWithUser:self.profile];
    }
}

@end
