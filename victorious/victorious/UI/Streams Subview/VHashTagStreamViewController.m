//
//  VHashTagStreamViewController.m
//  victorious
//
//  Created by Lawrence Leach on 7/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAnalyticsRecorder.h"
#import "VHashTagStreamViewController.h"
#import "VConstants.h"
#import "VSequence+Fetcher.h"
#import "VStreamTableViewController+ContentCreation.h"
#import "VObjectManager+Pagination.h"

#import "VThemeManager.h"

#import "UIImageView+Blurring.h"
#import "UIImage+ImageCreation.h"

#import "MBProgressHUD.h"

@interface VHashTagStreamViewController () <UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton* backButton;
@property (weak, nonatomic) IBOutlet UILabel* titleLabel;

@property (strong, nonatomic) IBOutlet UIImageView* backgroundImage;


@end
@implementation VHashTagStreamViewController

+ (VHashTagStreamViewController *)sharedInstance
{
    static  VHashTagStreamViewController *sharedInstance;
    static  dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        sharedInstance = (VHashTagStreamViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kHashTagStreamStoryboardID];
    });
    
    return sharedInstance;
}

+ (instancetype)hashTagViewController
{
    UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VHashTagStreamViewController* tagsContainerViewController = (VHashTagStreamViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kHashTagStreamStoryboardID];
    
    return tagsContainerViewController;
}

- (void)setHashTag:(NSString *)hashTag
{
    _hashTag = hashTag;
    
    self.currentFilter = [[VObjectManager sharedManager] sequenceFilterForHashTag:hashTag];
    
    [self refreshWithCompletion:nil];
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    [self.backgroundImage removeFromSuperview];
    UIImageView* newBackgroundView = [[UIImageView alloc] initWithFrame:self.view.frame];
    
    UIImage* placeholderImage = [UIImage resizeableImageWithColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]];
    [newBackgroundView setLightBlurredImageWithURL:[[self.sequence initialImageURLs] firstObject]
                                  placeholderImage:placeholderImage];
    
    self.backgroundImage = newBackgroundView;
    [self.view insertSubview:self.backgroundImage atIndex:0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] startAppView:@"Hash Tage Search Stream"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] finishAppView];
}

- (NSString*)streamName
{
    return @"hashtag";
}

@end
