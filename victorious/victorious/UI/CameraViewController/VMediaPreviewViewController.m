//
//  VMediaPreviewViewController.m
//  victorious
//
//  Created by Josh Hinman on 4/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSURL+MediaType.h"
#import "VAnalyticsRecorder.h"
#import "VConstants.h"
#import "VImagePreviewViewController.h"
#import "VMediaPreviewViewController.h"
#import "VThemeManager.h"
#import "VVideoPreviewViewController.h"

static const NSTimeInterval   kAnimationDuration = 0.2;
static       NSString * const kNibName           = @"MediaPreview";

@interface VMediaPreviewViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *deleteButton;
@property (nonatomic, weak) IBOutlet UIImageView *deleteConfirmationButton;
@property (nonatomic, weak) IBOutlet UIButton    *doneButton;

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
    [[VAnalyticsRecorder sharedAnalyticsRecorder] startAppView:@"Camera Preview"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] finishAppView];
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
    [self willComplete];
    if (self.completionBlock)
    {
        self.completionBlock(YES, [self previewImage], self.mediaURL);
    }
}

- (IBAction)deleteTapped:(id)sender
{
    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryCamera action:@"Trash" label:nil value:nil];
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
    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryCamera action:@"Trash Confirm" label:nil value:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)mediaPreviewTapped:(id)sender
{
    if (self.deleteConfirmationButton.hidden)
    {
        return;
    }
    
    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryCamera action:@"Trash Canceled" label:nil value:nil];
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
    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryCamera action:@"Cancel Media Capture" label:nil value:nil];
    if (self.completionBlock)
    {
        self.completionBlock(NO, nil, nil);
    }
}

@end
