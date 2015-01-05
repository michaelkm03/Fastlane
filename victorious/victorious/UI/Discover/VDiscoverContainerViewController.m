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
#import "VSettingManager.h"
#import "VDiscoverViewControllerProtocol.h"

@interface VDiscoverContainerViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarHeightConstraint;

@property (nonatomic, weak) IBOutlet UIView *searchBarContainer;
@property (nonatomic, weak) id<VDiscoverViewControllerProtocol> childViewController;

@end

@implementation VDiscoverContainerViewController

#pragma mark - Initializers

+ (VDiscoverContainerViewController *)instantiateFromStoryboard:(NSString *)storyboardName
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle bundleForClass:[self class]]];
    return [storyboard instantiateViewControllerWithIdentifier:@"discover"];
}

#pragma mark VHasManagedDependencies conforming initializer

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    return [self instantiateFromStoryboard:@"Discover"];
}

#pragma mark -

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
    
    NSLayoutConstraint *searchTopConstraint = [NSLayoutConstraint constraintWithItem:self.searchBarContainer
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.topLayoutGuide
                                                                          attribute:NSLayoutAttributeBottom
                                                                         multiplier:1.0
                                                                           constant:0];
    [self.view addConstraint:searchTopConstraint];
    [self.view layoutIfNeeded];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue.destinationViewController conformsToProtocol:@protocol(VDiscoverViewControllerProtocol)] )
    {
        self.childViewController = (id<VDiscoverViewControllerProtocol>)segue.destinationViewController;
    }
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

#pragma mark - VNavigationDestination

- (BOOL)shouldNavigateWithAlternateDestination:(UIViewController *__autoreleasing *)alternateViewController
{
    [self.childViewController refresh:YES];
    
    return YES;
}

@end
