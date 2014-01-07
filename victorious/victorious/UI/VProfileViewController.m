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
#import "UIImage+ImageEffects.h"

@interface VProfileViewController () <UIActionSheetDelegate, UITextFieldDelegate>
@property (nonatomic, readwrite) IBOutlet UIImageView* backgroundImageView;

@property (nonatomic, readwrite) IBOutlet UILabel* nameLabel;
@property (nonatomic, readwrite) IBOutlet UILabel* descriptionLabel;
@property (nonatomic, readwrite) IBOutlet UILabel* locationLabel;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // TODO: Check if the profile belongs to the logged in user
    self.profileBelongsToUser = YES;
    
    // Set label properties, how it looks, etc.
    [self setLabelProperties];
    
    // Set profile data - returns a BOOL
    [self setProfileData];
    
    if (self.profileBelongsToUser)
    {
        // Do nothing - edit button in Storyboard
    }
    else
    {
        // If the user is not logged in, create a compose button and user action button
        UIBarButtonItem* composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeButtonPressed)];
        UIBarButtonItem* userActionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(userActionButtonPressed)];
        self.navigationItem.rightBarButtonItems = @[composeButton, userActionButton];
    }
}

- (BOOL)setProfileData
{
    // TODO: Set the background here using core data
    UIImage* background = [UIImage imageNamed:@"avatar.jpg"];
    self.backgroundImageView.image = background;
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    // TODO: Add code to set the labels here
    self.nameLabel.text = @"NAME";
    self.descriptionLabel.text = @"DESCRIPTION";
    self.locationLabel.text = @"LOCATION";
    
    return YES;
}

- (void)setLabelProperties
{
    UIColor* transparentGray = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:0.6];
    self.nameLabel.backgroundColor = transparentGray;
    self.descriptionLabel.backgroundColor = transparentGray;
    self.locationLabel.backgroundColor = transparentGray;
}

-(void)composeButtonPressed
{
    // TODO: Should go to compose message view
    NSLog(@"Compose Button Clicked");
}

-(void)userActionButtonPressed
{
    // TODO: Replace action buttons with 
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Title"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel Button"
                                              destructiveButtonTitle:@"Destructive Button"
                                                   otherButtonTitles:@"Other Button 1",
                                 @"Other Button 2", nil];
    
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque; [popupQuery showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(int)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"Destructive Button Clicked");
    } else if (buttonIndex == 1) {
        NSLog(@"Other Button 1 Clicked");
    } else if (buttonIndex == 2) {
        NSLog(@"Other Button 2 Clicked");
    } else if (buttonIndex == 3) {
        NSLog(@"Cancel Button Clicked");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[VMenuViewController class]])
    {
        VMenuViewController *menuViewController = segue.destinationViewController;
        menuViewController.transitioningDelegate = (id <UIViewControllerTransitioningDelegate>)[VMenuViewControllerTransitionDelegate new];
        menuViewController.modalPresentationStyle = UIModalPresentationCustom;
    }
}

@end
