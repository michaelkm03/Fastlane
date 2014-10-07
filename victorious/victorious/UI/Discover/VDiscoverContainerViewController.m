//
//  VDiscoverContainerViewController.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDiscoverContainerViewController.h"
#import "VDiscoverConstants.h"
#import "VUser.h"
#import "VUserProfileViewController.h"

@interface VDiscoverContainerViewController ()

@property (nonatomic, weak) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarHeightConstraint;

@end

@implementation VDiscoverContainerViewController

+ (VDiscoverContainerViewController *)instantiateFromStoryboard:(NSString *)storyboardName
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle bundleForClass:[self class]]];
    return [storyboard instantiateViewControllerWithIdentifier:@"discover"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // For now, search is hidden.  Uncomment this when the time comes to implement it.
    self.searchBarHeightConstraint.constant = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSuggestedPersonProfile:) name:kVDiscoverUserProfileSelectedNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.headerLabel.text = NSLocalizedString(@"Discover", nil);
}

- (void)showSuggestedPersonProfile:(NSNotification *)note
{
    if ( note.userInfo == nil )
    {
        return;
    }
    
    VUser *user = note.userInfo[ kVDiscoverUserProfileSelectedKeyUser ];
    if ( user == nil )
    {
        return;
    }
    
    VUserProfileViewController *profileViewController = [VUserProfileViewController userProfileWithUser:user];
    if ( self.navigationController != nil )
    {
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
    else
    {
        [self presentViewController:profileViewController animated:YES completion:nil];
    }
}

@end
