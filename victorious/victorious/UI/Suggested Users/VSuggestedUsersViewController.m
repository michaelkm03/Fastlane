//
//  VSuggestedUsersViewController.m
//  victorious
//
//  Created by Patrick Lynch on 6/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSuggestedUsersViewController.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VSuggestedUsersDataSource.h"
#import "UIView+AutoLayout.h"
#import "VLoginFlowControllerDelegate.h"
#import "VAppInfo.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "VLinearGradientView.h"
#import "VDependencyManager+VLoginAndRegistration.h"
#import "VSuggestedUserRetryCell.h"

@interface VSuggestedUsersViewController () <VBackgroundContainer, UICollectionViewDelegateFlowLayout, VLoginFlowScreen>

@property (nonatomic, weak) IBOutlet UIView *collectionContainer;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *creatorMessageContainerHeight;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *salutationContainerHeight;

@property (nonatomic, weak) IBOutlet UILabel *creatorNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *creatorAvatarImageView;
@property (nonatomic, weak) IBOutlet UIImageView *quoteImageView;
@property (nonatomic, weak) IBOutlet UITextView *messageTextView;

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VSuggestedUsersDataSource *suggestedUsersDataSource;
@property (nonatomic, strong) VLinearGradientView *gradientMaskView;

@property (nonatomic, assign) BOOL didTransitionIn;
@property (nonatomic, readonly) BOOL isFinalRegistrationScreen;

@end

@implementation VSuggestedUsersViewController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *nib = NSStringFromClass([self class]);
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    self = [super initWithNibName:nib bundle:bundle];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.dependencyManager addBackgroundToBackgroundHost:self];
    
    VAppInfo *appInfo = [[VAppInfo alloc] initWithDependencyManager:self.dependencyManager];
    NSString *ownerName = appInfo.ownerName;
    NSURL *profileImageURL = appInfo.profileImageURL;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.creatorAvatarImageView.layer.cornerRadius = CGRectGetMidX( self.creatorAvatarImageView.bounds );
    self.creatorAvatarImageView.layer.borderWidth = 1.0f;
    self.creatorAvatarImageView.layer.borderColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey].CGColor;
    self.creatorAvatarImageView.layer.masksToBounds = YES;
    
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake( 5, 0, 0, 0 );
    
    BOOL stringIsValid = ownerName != nil && ownerName.length > 0;
    BOOL profileImageURLIsEmpty = [profileImageURL.absoluteString isEqualToString:@""];
    if ( stringIsValid && !profileImageURLIsEmpty )
    {
        self.creatorNameLabel.text = ownerName;
        self.creatorNameLabel.font = [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
        self.creatorNameLabel.textColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryTextColorKey];
        
        self.quoteImageView.image = [self.quoteImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.quoteImageView.tintColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
        
        [self.creatorAvatarImageView sd_setImageWithURL:profileImageURL placeholderImage:nil];
    }
    else
    {
        self.salutationContainerHeight.constant = 0.0f;
    }
    
    self.messageTextView.text = [self.dependencyManager stringForKey:VScreenPromptKey];
    self.messageTextView.font = [self.dependencyManager fontForKey:VDependencyManagerHeading3FontKey];
    self.messageTextView.textColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    self.messageTextView.contentInset = UIEdgeInsetsZero;
    self.messageTextView.textContainer.lineFragmentPadding = 0.0f;
    self.messageTextView.textContainerInset = UIEdgeInsetsMake( 4.0, 0.0, 4.0, 0.0 );
    
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.suggestedUsersDataSource = [[VSuggestedUsersDataSource alloc] initWithDependencyManager:self.dependencyManager];
    [self.suggestedUsersDataSource registerCellsForCollectionView:self.collectionView];
    self.collectionView.dataSource = self.suggestedUsersDataSource;
    
    [self.activityIndicator startAnimating];
    [self refreshSuggestedUsers];
    
    self.activityIndicator.color = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    UIImage *emptyImage = [[UIImage alloc] init];
    [self.navigationController.navigationBar setBackgroundImage:emptyImage forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = emptyImage;
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    self.collectionView.transform = CGAffineTransformMakeTranslation( 0, CGRectGetHeight(self.collectionView.frame) );
    
    [self.delegate configureFlowNavigationItemWithScreen:self];
    self.navigationItem.hidesBackButton = YES;
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    self.gradientMaskView = [[VLinearGradientView alloc] initWithFrame:self.collectionContainer.bounds];
    [self.gradientMaskView setColors:@[[UIColor clearColor], [UIColor blackColor]]];
    [self.gradientMaskView setLocations:@[ @(0.0), @(10.0 / CGRectGetHeight(self.collectionContainer.bounds)) ]];
    self.collectionContainer.maskView = self.gradientMaskView;
}

- (void)suggestedUsersDidLoad
{
    [self.activityIndicator stopAnimating];
    
    [self.collectionView reloadData];
    
    if ( !self.didTransitionIn )
    {
        self.didTransitionIn = YES;
        
        [UIView animateWithDuration:0.5f
                              delay:0.0f
             usingSpringWithDamping:0.8f
              initialSpringVelocity:0.2f
                            options:kNilOptions
                         animations:^
         {
             self.collectionView.transform = CGAffineTransformMakeTranslation( 0, 0 );
         }
                         completion:^(BOOL finished)
         {
             [self.collectionView flashScrollIndicators];
         }];
    }
}

#pragma mark - VLoginFlowScreen

@synthesize delegate = _delegate;

- (BOOL)displaysAfterSocialRegistration
{
    NSNumber *value = [self.dependencyManager numberForKey:VDisplayWithSocialRegistration];
    return value.boolValue;
}

- (void)onContinue:(id)sender
{
    [self.delegate continueRegistrationFlow];
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self.view;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.suggestedUsersDataSource collectionView:collectionView sizeForItemAtIndexPath:indexPath];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake( 12.0f, 0, 10.0f, 0 );
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ( self.suggestedUsersDataSource.isDisplayingRetryCell )
    {
        [self refreshSuggestedUsers];
    }
}

- (void)refreshSuggestedUsers
{
    __weak typeof(self) welf = self;
    [self.suggestedUsersDataSource refreshWithCompletion:^
     {
         [welf suggestedUsersDidLoad];
     }];
}

@end
