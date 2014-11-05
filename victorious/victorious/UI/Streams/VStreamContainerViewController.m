//
//  VStreamContainerViewController.m
//  victorious
//
//  Created by Will Long on 5/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamContainerViewController.h"

#import "VLoginViewController.h"
#import "VUploadProgressViewController.h"

#import "VCameraViewController.h"
#import "VCameraPublishViewController.h"
#import "VObjectManager+ContentCreation.h"
#import "UIActionSheet+VBlocks.h"

#import "VThemeManager.h"
#import "VObjectManager.h"

#import "VStream.h"

#import "VConstants.h"

#import "VAuthorizationViewControllerFactory.h"
#import "VObjectManager+Login.h"

@interface VStreamContainerViewController () <VUploadProgressViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIButton *createButton;
@property (nonatomic, strong) VUploadProgressViewController *uploadProgressViewController;
@property (nonatomic, strong) NSLayoutConstraint *uploadProgressViewYconstraint;

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
    
    if (self.shouldShowUploadProgress)
    {
        [self configureUploadProgressView];
    }
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
    self.streamTable.hashTag = hashTag;
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
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
    }
    
    [super changedFilterControls:sender];
    
    self.streamTable.filterType = self.filterControls.selectedSegmentIndex;
    
    if (sender) // sender is nil if this method is called directly (not in response to a user touch)
    {
        NSString *streamName = nil;
        switch (self.filterControls.selectedSegmentIndex)
        {
            case VStreamFilterFeatured:
                streamName = @"Featured";
                break;
                
            case VStreamFilterRecent:
                streamName = @"Recent";
                break;
                
            case VStreamFilterFollowing:
                streamName = @"Following";
                break;
                
            default:
                break;
        }
        
        if ( streamName )
        {
            NSDictionary *params = @{ VTrackingKeyStreamName : streamName };
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectStream parameters:params];
        }
    }
}

- (CGFloat)hiddenHeaderHeight
{
    if ([self isUploadProgressVisible])
    {
        return [super hiddenHeaderHeight] + VUploadProgressViewControllerIdealHeight;
    }
    return [super hiddenHeaderHeight];
}

#pragma mark - Upload Progress View

- (void)configureUploadProgressView
{
    self.uploadProgressViewController = [VUploadProgressViewController viewControllerForUploadManager:[[VObjectManager sharedManager] uploadManager]];
    self.uploadProgressViewController.delegate = self;
    [self addChildViewController:self.uploadProgressViewController];
    self.uploadProgressViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:self.uploadProgressViewController.view belowSubview:self.headerView];
    [self.uploadProgressViewController didMoveToParentViewController:self];

    UIView *upvc = self.uploadProgressViewController.view;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[upvc]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(upvc)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:upvc
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0f
                                                           constant:VUploadProgressViewControllerIdealHeight]];
    
    self.uploadProgressViewYconstraint = [NSLayoutConstraint constraintWithItem:upvc
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.headerView
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1.0f
                                                                       constant:-VUploadProgressViewControllerIdealHeight];
    [self.view addConstraint:self.uploadProgressViewYconstraint];

    if (self.uploadProgressViewController.numberOfUploads)
    {
        [self v_showUploads];
    }
}

- (void)v_showUploads
{
    self.uploadProgressViewYconstraint.constant = 0;
}

- (BOOL)isUploadProgressVisible
{
    return self.uploadProgressViewController != nil && self.uploadProgressViewYconstraint.constant == 0;
}

- (void)v_hideUploads
{
    self.uploadProgressViewYconstraint.constant = -VUploadProgressViewControllerIdealHeight;
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
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return;
    }
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectCreatePost];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    cancelButtonTitle:NSLocalizedString(@"CancelButton", @"Cancel button")
                                                       onCancelButton:nil
                                               destructiveButtonTitle:nil
                                                  onDestructiveButton:nil
                                           otherButtonTitlesAndBlocks:
                                  NSLocalizedString(@"Create a Video Post", @""), ^(void)
                                  {
                                      [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateVideoPostSelected];
                                      
                                      [self presentCameraViewController:[VCameraViewController cameraViewController]];
                                  },
                                  NSLocalizedString(@"Create an Image Post", @""), ^(void)
                                  {
                                      [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateImagePostSelected];
                                      
                                      [self presentCameraViewController:[VCameraViewController cameraViewControllerStartingWithStillCapture]];
                                  },
                                  NSLocalizedString(@"Create a Poll", @""), ^(void)
                                  {
                                      [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreatePollSelected];
                                      
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

#pragma mark - VUploadProgressViewControllerDelegate methods

- (void)uploadProgressViewController:(VUploadProgressViewController *)upvc isNowDisplayingThisManyUploads:(NSInteger)uploadCount
{
    if (uploadCount)
    {
        [self v_showUploads];
    }
    else
    {
        [self v_hideUploads];
    }
}

@end
