//
//  VStreamContainerViewController.m
//  victorious
//
//  Created by Will Long on 5/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamContainerViewController.h"

#import "VLoginViewController.h"

#import "VHashTagStreamViewController.h"

#import "VCameraViewController.h"
#import "VCameraPublishViewController.h"
#import "VObjectManager+ContentCreation.h"
#import "UIActionSheet+VBlocks.h"

#import "VThemeManager.h"
#import "VObjectManager.h"

#import "VStream.h"

#import "VAnalyticsRecorder.h"
#import "VConstants.h"

#import "VAuthorizationViewControllerFactory.h"
#import "VObjectManager+Login.h"

@interface VStreamContainerViewController ()

@property (nonatomic, weak) IBOutlet UIButton *createButton;

@end

@implementation VStreamContainerViewController

+ (instancetype)containerForStreamTable:(VStreamTableViewController *)streamTable
{
    UIViewController   *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VStreamContainerViewController *container = (VStreamContainerViewController *)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kStreamContainerID];
    container.tableViewController = streamTable;
    container.automaticallyAdjustsScrollViewInsets = NO;
    streamTable.delegate = container;
    
    return container;
}

+ (instancetype)modalContainerForStreamTable:(VStreamTableViewController *)streamTable
{
    UIViewController   *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VStreamContainerViewController *container = (VStreamContainerViewController *)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kModalStreamContainerID];
    container.tableViewController = streamTable;
    container.automaticallyAdjustsScrollViewInsets = NO;
    streamTable.delegate = container;
    
    return container;
}

- (VStreamTableViewController *)streamTable
{
    return (VStreamTableViewController *)self.tableViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.createButton.hidden = [self.streamTable.defaultStream.apiPath isEqualToString:[VStreamTableViewController ownerStream].defaultStream.apiPath];
    self.createButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    UIImage *image = [self.createButton.currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.createButton setImage:image forState:UIControlStateNormal];
    
    if (![self.streamTable.defaultStream.apiPath isEqualToString:[VStreamTableViewController homeStream].defaultStream.apiPath])
    {
        [self.filterControls removeSegmentAtIndex:VStreamFilterFollowing animated:NO];
    }
    
    [self.filterControls setSelectedSegmentIndex:VStreamFilterRecent];
    [self changedFilterControls:nil];
    
    UIView *tableContainerView = self.tableContainerView;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableContainerView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableContainerView)]];
    
    [self.filterControls setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:12]}
                                       forState:UIControlStateNormal];
    
    [self.filterControls setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:12],
                                                  NSForegroundColorAttributeName: [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor]}
                                       forState:UIControlStateSelected];
    
    [self configureHeaderImage];
    [self configureSegmentedControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.hashTag)
    {
        NSString *titleText = [NSString stringWithFormat:@"#%@", self.hashTag];
        self.headerLabel.text = NSLocalizedString(titleText, nil);
    }
}

- (void)setHashTag:(NSString *)hashTag
{
    _hashTag = hashTag;
}

- (void)configureHeaderImage
{
    if (!self.shouldShowHeaderLogo)
    {
        return;
    }
    
    UIImage *headerImage = [[VThemeManager sharedThemeManager] themedImageForKey:VThemeManagerHomeHeaderImageKey];
    if (headerImage)
    {
        self.headerImageView.image = headerImage;
        self.headerLabel.hidden = YES;
    }
    else
    {
        self.headerImageView.hidden = YES;
    }
}

- (void)configureSegmentedControl
{
    [self.filterControls setDividerImage:[UIImage imageNamed:@"segmentedControlSeperatorLeftUnselected"]
                     forLeftSegmentState:UIControlStateNormal
                       rightSegmentState:UIControlStateSelected
                              barMetrics:UIBarMetricsDefault];
    [self.filterControls setDividerImage:[UIImage imageNamed:@"segmentedControlSeperatorRightUnselected"]
                     forLeftSegmentState:UIControlStateSelected
                       rightSegmentState:UIControlStateNormal
                              barMetrics:UIBarMetricsDefault];
    [self.filterControls setBackgroundImage:[UIImage imageNamed:@"segmentedControlBorderUnselected"]
                                   forState:UIControlStateNormal
                                 barMetrics:UIBarMetricsDefault];
    [self.filterControls setBackgroundImage:[UIImage imageNamed:@"segmentedControlBorderSelected"]
                                   forState:UIControlStateSelected
                                 barMetrics:UIBarMetricsDefault];
}

- (IBAction)changedFilterControls:(id)sender
{
    if (self.filterControls.selectedSegmentIndex == VStreamFilterFollowing && ![VObjectManager sharedManager].authorized)
    {
        [self.filterControls setSelectedSegmentIndex:self.streamTable.filterType];
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewController:[VObjectManager sharedManager]] animated:YES completion:NULL];
    }
    
    [super changedFilterControls:sender];
    
    self.streamTable.filterType = self.filterControls.selectedSegmentIndex;
    
    if (sender) // sender is nil if this method is called directly (not in response to a user touch)
    {
        NSString *eventAction = nil;
        switch (self.filterControls.selectedSegmentIndex)
        {
            case VStreamFilterFeatured:
                eventAction = @"Selected Filter: Featured";
                break;
                
            case VStreamFilterRecent:
                eventAction = @"Selected Filter: Recent";
                break;
                
            case VStreamFilterFollowing:
                eventAction = @"Selected Filter: Following";
                break;
                
            default:
                break;
        }
        
        if (eventAction)
        {
            [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryNavigation action:eventAction label:nil value:nil];
        }
    }
}

#pragma mark - Content Creation

- (void)addCreateButton
{
    
    UIBarButtonItem *createButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"createContentButton"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(createButtonAction:)];
    
    self.navigationItem.rightBarButtonItems =  [@[createButtonItem] arrayByAddingObjectsFromArray:self.navigationItem.rightBarButtonItems];
}

- (IBAction)createButtonAction:(id)sender
{
    if (![VObjectManager sharedManager].authorized)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewController:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return;
    }
    
    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryInteraction
                                                                 action:@"Create Button Tapped"
                                                                  label:nil
                                                                  value:nil];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
                                                       onCancelButton:nil
                                               destructiveButtonTitle:nil
                                                  onDestructiveButton:nil
                                           otherButtonTitlesAndBlocks:
                                  NSLocalizedString(@"Create a Video Post", @""), ^(void)
                                  {
                                      [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryNavigation
                                                                                                   action:@"Selected Create Video Post"
                                                                                                    label:nil
                                                                                                    value:nil];
                                      [self presentCameraViewController:[VCameraViewController cameraViewController]];
                                  },
                                  NSLocalizedString(@"Create an Image Post", @""), ^(void)
                                  {
                                      [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryNavigation
                                                                                                   action:@"Selected Create Image Post"
                                                                                                    label:nil
                                                                                                    value:nil];
                                      [self presentCameraViewController:[VCameraViewController cameraViewControllerStartingWithStillCapture]];
                                  },
                                  NSLocalizedString(@"Create a Poll", @""), ^(void)
                                  {
                                      [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryNavigation
                                                                                                   action:@"Selected Create Poll"
                                                                                                    label:nil
                                                                                                    value:nil];
                                      VCreatePollViewController *createViewController = [VCreatePollViewController newCreatePollViewController];
                                      [self.navigationController pushViewController:createViewController animated:YES];
                                  }, nil];
    [actionSheet showInView:self.view];
}

- (void)presentCameraViewController:(VCameraViewController *)cameraViewController
{
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    UINavigationController *__weak weakNav = navigationController;
    VCameraViewController *__weak weakCamera = cameraViewController;
    cameraViewController.completionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        if (!finished || !capturedMediaURL)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            VCameraPublishViewController *publishViewController = [VCameraPublishViewController cameraPublishViewController];
            publishViewController.previewImage = previewImage;
            publishViewController.mediaURL = capturedMediaURL;
            publishViewController.didSelectAssetFromLibrary = weakCamera.didSelectAssetFromLibrary;
            publishViewController.completion = ^(BOOL complete)
            {
                if (complete)
                {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                else
                {
                    [weakNav popViewControllerAnimated:YES];
                }
            };
            [weakNav pushViewController:publishViewController animated:YES];
        }
    };
    [navigationController pushViewController:cameraViewController animated:NO];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Navigation

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if ([self.streamTable respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)])
    {
        return [(UIViewController<UINavigationControllerDelegate> *)self.streamTable navigationController:navigationController
                                                                         animationControllerForOperation:operation
                                                                                      fromViewController:fromVC
                                                                                        toViewController:toVC];
    }
    else
    {
        return nil;
    }
}

@end
