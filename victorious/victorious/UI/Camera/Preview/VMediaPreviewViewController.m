//
//  VMediaPreviewViewController.m
//  victorious
//
//  Created by Josh Hinman on 4/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSURL+MediaType.h"
#import "UIActionSheet+VBlocks.h"
#import "VImagePreviewViewController.h"
#import "VMediaPreviewViewController.h"
#import "VThemeManager.h"
#import "VVideoPreviewViewController.h"

static const NSTimeInterval   kAnimationDuration = 0.2;
static       NSString * const kNibName           = @"VMediaPreviewViewController";

@interface VMediaPreviewViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *deleteButton;
@property (nonatomic, weak) IBOutlet UIImageView *deleteConfirmationButton;
@property (nonatomic, weak, readwrite) IBOutlet UIButton    *doneButton;
@property (nonatomic, weak, readwrite) IBOutlet UIButton    *nextButton;

@end

@implementation VMediaPreviewViewController

+ (VMediaPreviewViewController *)previewViewControllerForMediaAtURL:(NSURL *)mediaURL
{
    VMediaPreviewViewController *previewViewController = nil;
    if ([mediaURL v_hasImageExtension])
    {
        previewViewController = [[VImagePreviewViewController alloc] initWithMediaURL:mediaURL];
    }
    else if ([mediaURL v_hasVideoExtension])
    {
        previewViewController = [[VVideoPreviewViewController alloc] initWithMediaURL:mediaURL];
    }
    return previewViewController;
}

- (instancetype)initWithMediaURL:(NSURL *)mediaURL
{
    self = [super initWithNibName:kNibName bundle:nil];
    if (self)
    {
        _mediaURL = mediaURL;
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *doneButtonImage = [self.doneButton imageForState:UIControlStateNormal];
    doneButtonImage = [doneButtonImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.doneButton setImage:doneButtonImage forState:UIControlStateNormal];
    self.doneButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:VTrackingEventCameraPreviewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VTrackingManager sharedInstance] endEvent:VTrackingEventCameraPreviewDidAppear];
}

#pragma mark -

- (UIView *)previewImage
{
    NSAssert(NO, @"previewImage not implemented in %@", NSStringFromClass([self class]));
    return nil;
}

- (void)willComplete
{
    // This method intentionally left blank
}

#pragma mark - Actions

- (IBAction)doneTapped:(UIButton *)sender
{
    // if we're in step one of the two-step delete confirmation flow, tapping the "done" button should cancel the delete
    if (!self.deleteConfirmationButton.hidden)
    {
        [self mediaPreviewTapped:nil];
        return;
    }

    self.doneButton.userInteractionEnabled = NO;
    [self willComplete];
    if (self.completionBlock)
    {
        self.completionBlock(YES, [self previewImage], self.mediaURL);
    }
    self.doneButton.userInteractionEnabled = YES;
}

- (IBAction)deleteTapped:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidSelectDelete];
    
    CGRect deleteButtonBounds = self.deleteButton.bounds;
    CGRect deleteConfirmationBounds = self.deleteConfirmationButton.bounds;
    self.deleteConfirmationButton.bounds = deleteButtonBounds;
    self.deleteConfirmationButton.transform = CGAffineTransformMakeRotation(3.0 * M_PI_2);
    self.deleteConfirmationButton.alpha = 0;
    self.deleteConfirmationButton.hidden = NO;
    [UIView animateWithDuration:kAnimationDuration
                     animations:^(void)
    {
        self.deleteButton.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.deleteButton.alpha = 0;
        self.deleteButton.bounds = deleteConfirmationBounds;
        self.deleteConfirmationButton.transform = CGAffineTransformIdentity;
        self.deleteConfirmationButton.alpha = 1.0f;
        self.deleteConfirmationButton.bounds = deleteConfirmationBounds;
    }
                     completion:^(BOOL finished)
    {
        self.deleteButton.transform = CGAffineTransformIdentity;
        self.deleteButton.hidden = YES;
        self.deleteButton.alpha = 1.0f;
        self.deleteButton.bounds = deleteButtonBounds;
    }];
}

- (IBAction)deleteConfirmationTapped:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidSelectDelete];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backTapped:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidGoBack];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)mediaPreviewTapped:(id)sender
{
    if (self.deleteConfirmationButton.hidden)
    {
        return;
    }
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidCancelDelete];
    
    CGRect deleteButtonBounds = self.deleteButton.bounds;
    CGRect deleteConfirmationBounds = self.deleteConfirmationButton.bounds;
    self.deleteButton.bounds = deleteConfirmationBounds;
    self.deleteButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.deleteButton.alpha = 0;
    self.deleteButton.hidden = NO;
    [UIView animateWithDuration:kAnimationDuration
                     animations:^(void)
    {
        self.deleteConfirmationButton.transform = CGAffineTransformMakeRotation(3.0 * M_PI_2);
        self.deleteConfirmationButton.alpha = 0;
        self.deleteConfirmationButton.bounds = deleteButtonBounds;
        self.deleteButton.transform = CGAffineTransformIdentity;
        self.deleteButton.alpha = 1.0f;
        self.deleteButton.bounds = deleteButtonBounds;
    }
                     completion:^(BOOL finished)
    {
        self.deleteConfirmationButton.transform = CGAffineTransformIdentity;
        self.deleteConfirmationButton.hidden = YES;
        self.deleteConfirmationButton.alpha = 1.0f;
        self.deleteConfirmationButton.bounds = deleteConfirmationBounds;
    }];
}

- (IBAction)cancelTapped:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ClosePreviewConfirm", @"")
                                                    cancelButtonTitle:NSLocalizedString(@"Stay", @"")
                                                       onCancelButton:nil
                                               destructiveButtonTitle:NSLocalizedString(@"Close", @"")
                                                  onDestructiveButton:^(void)
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserCancelMediaCapture];

        if (self.completionBlock)
        {
            self.completionBlock(NO, nil, nil);
        }
    }
                                           otherButtonTitlesAndBlocks:nil];
    [actionSheet showInView:self.view];
}

@end
