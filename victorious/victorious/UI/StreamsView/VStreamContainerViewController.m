//
//  VStreamContainerViewController.m
//  victorious
//
//  Created by Will Long on 5/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamContainerViewController.h"


#import "VLoginViewController.h"

#import "VHomeStreamViewController.h"
#import "VOwnerStreamViewController.h"
#import "VCommunityStreamViewController.h"

#import "VCameraViewController.h"
#import "VCameraPublishViewController.h"
#import "VObjectManager+ContentCreation.h"
#import "UIActionSheet+VBlocks.h"

#import "VThemeManager.h"
#import "VObjectManager.h"

#import "VAnalyticsRecorder.h"
#import "VConstants.h"

@interface VStreamContainerViewController () <VCreateSequenceDelegate>

@property (nonatomic, weak) IBOutlet UIButton* createButton;

@property (nonatomic, getter = streamTable) VStreamTableViewController* streamTable;

@end

@implementation VStreamContainerViewController

+ (instancetype)containerForStreamTable:(VStreamTableViewController*)streamTable
{
    UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VStreamContainerViewController* container = (VStreamContainerViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kStreamContainerID];
    container.tableViewController = streamTable;
    streamTable.delegate = container;
    
    return container;
}

- (VStreamTableViewController*)streamTable
{
    return (VStreamTableViewController*)self.tableViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.streamTable.view
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0]];

    self.createButton.hidden = [self.streamTable isKindOfClass:[VOwnerStreamViewController class]];
    self.createButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    UIImage* image = [self.createButton.currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.createButton setImage:image forState:UIControlStateNormal];
    
    if (![self.streamTable isKindOfClass:[VHomeStreamViewController class]])
    {
        [self.filterControls removeSegmentAtIndex:VStreamFollowingFilter animated:NO];
    }
    
    [self.filterControls setSelectedSegmentIndex:VStreamRecentFilter];
    [self changedFilterControls:nil];
}

- (IBAction)changedFilterControls:(id)sender
{
    if (self.filterControls.selectedSegmentIndex == VStreamFollowingFilter && ![VObjectManager sharedManager].mainUser)
    {
        [self.filterControls setSelectedSegmentIndex:self.streamTable.filterType];
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
    }
    
    [super changedFilterControls:sender];
    
    self.streamTable.filterType = self.filterControls.selectedSegmentIndex;
    
    if (sender) // sender is nil if this method is called directly (not in response to a user touch)
    {
        NSString *eventAction = nil;
        switch (self.filterControls.selectedSegmentIndex) {
            case VStreamHotFilter:
                eventAction = @"Selected Filter: Hot";
                break;
                
            case VStreamRecentFilter:
                eventAction = @"Selected Filter: Recent";
                break;
                
            case VStreamFollowingFilter:
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
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
                                                       onCancelButton:nil
                                               destructiveButtonTitle:nil
                                                  onDestructiveButton:nil
                                           otherButtonTitlesAndBlocks:
                                  NSLocalizedString(@"Create a Video Post", @""), ^(void)
                                  {
                                      [self presentCameraViewController:[VCameraViewController cameraViewController]];
                                  },
                                  NSLocalizedString(@"Create an Image Post", @""), ^(void)
                                  {
                                      [self presentCameraViewController:[VCameraViewController cameraViewControllerStartingWithStillCapture]];
                                  },
                                  NSLocalizedString(@"Create a Poll", @""), ^(void)
                                  {
                                      VCreatePollViewController *createViewController = [VCreatePollViewController newCreatePollViewControllerWithDelegate:self];
                                      [self.navigationController pushViewController:createViewController animated:YES];
                                  }, nil];
    [actionSheet showInView:self.view];
}

- (void)presentCameraViewController:(VCameraViewController *)cameraViewController
{
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    UINavigationController * __weak weakNav = navigationController;
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

- (void)createPollWithQuestion:(NSString *)question
                   answer1Text:(NSString *)answer1Text
                   answer2Text:(NSString *)answer2Text
                     media1URL:(NSURL *)media1URL
                     media2URL:(NSURL *)media2URL
{
    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        NSLog(@"%@", resultObjects);
    };
    
    VFailBlock fail = ^(NSOperation* operation, NSError* error)
    {
        NSLog(@"%@", error);
        
        if (kVStillTranscodingError == error.code)
        {
            UIAlertView*    alert   = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TranscodingMediaTitle", @"")
                                                                 message:NSLocalizedString(@"TranscodingMediaBody", @"")
                                                                delegate:nil
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
            [alert show];
        }
        else
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PollUploadTitle", @"")
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
            [alert show];
        }
    };
    
    [[VObjectManager sharedManager] createPollWithName:question
                                           description:@"<none>"
                                              question:question
                                           answer1Text:answer1Text
                                           answer2Text:answer2Text
                                             media1Url:media1URL
                                             media2Url:media2URL
                                          successBlock:success
                                             failBlock:fail];
}

#pragma mark - Navigation

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if ([self.streamTable respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)])
    {
        return [(UIViewController<UINavigationControllerDelegate>*)self.streamTable navigationController:navigationController
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
