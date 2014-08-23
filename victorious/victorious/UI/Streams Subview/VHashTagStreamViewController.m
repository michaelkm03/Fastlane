//
//  VHashTagStreamViewController.m
//  victorious
//
//  Created by Lawrence Leach on 7/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamTableDataSource.h"
#import "VHashTagStreamViewController.h"

#import "VAnalyticsRecorder.h"
#import "VConstants.h"
#import "VStreamTableViewController+ContentCreation.h"

//Cells
#import "VStreamViewCell.h"
#import "VStreamPollCell.h"

//ObjectManager
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Pagination.h"

//Data Models
#import "VSequence+RestKit.h"
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"

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

- (id)init
{
    return [self initWithHashTag:@""];
}

- (id)initWithHashTag:(NSString *)hashTag
{
    UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    self = [currentViewController.storyboard instantiateViewControllerWithIdentifier:kHashTagStreamStoryboardID];
    if (self)
    {
        [self setHashTag:hashTag];
    }
    return self;
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
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
}

- (NSString*)streamName
{
    return @"hashtag";
}

@end
