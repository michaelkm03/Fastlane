//
//  VStreamContainerViewController.m
//  victorious
//
//  Created by Will Long on 5/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamContainerViewController.h"

#import "UIViewController+VSideMenuViewController.h"

#import "VStreamTableViewController+ContentCreation.h"
#import "VHomeStreamViewController.h"
#import "VOwnerStreamViewController.h"
#import "VCommunityStreamViewController.h"

#import "VLoginViewController.h"

#import "VCameraViewController.h"
#import "VCameraPublishViewController.h"
#import "VObjectManager+ContentCreation.h"
#import "UIActionSheet+VBlocks.h"

#import "VThemeManager.h"

#import "VObjectManager.h"

#import "VConstants.h"

@interface VStreamContainerViewController ()

@property (nonatomic, strong) VStreamTableViewController* streamTable;

@property (nonatomic, weak) IBOutlet UIView* streamContainerView;
@property (nonatomic, weak) IBOutlet UIView* headerView;
@property (nonatomic, weak) IBOutlet UISegmentedControl* filterControls;
@property (nonatomic, weak) IBOutlet UILabel* headerLabel;
@property (nonatomic, weak) IBOutlet UIButton* menuButton;
@property (nonatomic, weak) IBOutlet UIButton* createButton;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* headerYConstraint;

@end

@implementation VStreamContainerViewController

+ (instancetype)containerForStreamTable:(VStreamTableViewController*)streamTable
{
    UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VStreamContainerViewController* container = (VStreamContainerViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kStreamContainerID];
    container.streamTable = streamTable;
    streamTable.delegate = container;
    
    return container;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.streamContainerView addSubview:self.streamTable.view];
    [self addChildViewController:self.streamTable];
    [self.streamTable didMoveToParentViewController:self];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.streamTable.view
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0]];

    self.headerView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.headerView.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    
    self.menuButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    UIImage* image = [self.menuButton.currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.menuButton setImage:image forState:UIControlStateNormal];
    
    self.createButton.hidden = [self.streamTable isKindOfClass:[VOwnerStreamViewController class]];
    self.createButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    image = [self.createButton.currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.createButton setImage:image forState:UIControlStateNormal];
    
    self.headerLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    self.headerLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.headerLabel.text = self.streamTable.navigationItem.title;
    
    self.filterControls.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    [[UISegmentedControl appearance] setTitleTextAttributes:@{
                                                              NSForegroundColorAttributeName : [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor]
                                                              } forState:UIControlStateNormal];
    self.filterControls.layer.cornerRadius = 8;
    self.filterControls.clipsToBounds = YES;
    [self changedFilterControls:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showMenu
{
    [self.sideMenuViewController presentMenuViewController];
}
#pragma mark - Header
- (void)hideHeader
{
    if (!CGRectContainsRect(self.view.frame, self.headerView.frame))
        return;
    
    self.headerYConstraint.constant = -self.headerView.frame.size.height;
    [self.view layoutIfNeeded];
}

- (void)showHeader
{
    if (CGRectContainsRect(self.view.frame, self.headerView.frame))
        return;
    
    self.headerYConstraint.constant = 0;
    [self.view layoutIfNeeded];
}

#pragma mark - FilterControls

- (IBAction)changedFilterControls:(id)sender
{
    if (self.filterControls.selectedSegmentIndex == VStreamFollowingFilter && ![VObjectManager sharedManager].mainUser)
    {
        [self.filterControls setSelectedSegmentIndex:self.streamTable.filterType];
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
    }
    
    for (int i = 0; i < self.filterControls.subviews.count; i++)
    {
        id view = self.filterControls.subviews[i];
        if (![view respondsToSelector:@selector(isSelected)]
            || ![view respondsToSelector:@selector(setTintColor:)]
            || ![view respondsToSelector:@selector(setBackgroundColor:)])
            continue;
        
        if ([view isSelected])
        {
            [view setTintColor: [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor]];
        }
        else
        {
            [view setTintColor: [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor]];
            [view setBackgroundColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor]];
        }
    }
    
    self.streamTable.filterType = self.filterControls.selectedSegmentIndex;
}

#pragma mark UITableViewDelegate

- (void)streamWillDisappear
{
    [UIView animateWithDuration:.2f
                     animations:^{
        [self hideHeader];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    
    if (translation.y < 0)
    {
        [UIView animateWithDuration:.2f animations:^
         {
             [self hideHeader];
         }];
    }
    else if (translation.y > 0)
    {
        [UIView animateWithDuration:.2f animations:^
         {
             [self showHeader];
         }];
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
    if(![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    NSString *contentTitle = NSLocalizedString(@"Post Content", @"Post content button");
    NSString *pollTitle = NSLocalizedString(@"Post Poll", @"Post poll button");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
                                                       onCancelButton:nil
                                               destructiveButtonTitle:nil
                                                  onDestructiveButton:nil
                                           otherButtonTitlesAndBlocks:contentTitle, ^(void)
                                  {
                                      UINavigationController *navigationController = [[UINavigationController alloc] init];
                                      UINavigationController * __weak weakNav = navigationController;
                                      VCameraViewController *cameraViewController = [VCameraViewController cameraViewController];
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
                                  },
                                  pollTitle, ^(void)
                                  {
                                      VCreatePollViewController *createViewController = [VCreatePollViewController newCreatePollViewControllerWithDelegate:self];
                                      [self.navigationController pushViewController:createViewController animated:YES];
                                  }, nil];
    [actionSheet showInView:self.view];
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

@end
