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
#import "VCreatorMessageViewController.h"
#import "UIView+AutoLayout.h"
#import "VLoginFlowControllerDelegate.h"
#import "VAppInfo.h"

static NSString * const kBarButtonTintColorKey      = @"color.text.label3";
static NSString * const VSuggestedUsersPromptKey    = @"prompt";

@interface VSuggestedUsersViewController () <VBackgroundContainer, UICollectionViewDelegateFlowLayout, VLoginFlowScreen>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *creatorMessageContainerHeight;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *salutationContainerHeight;

@property (nonatomic, weak) IBOutlet UILabel *creatorNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *creatorAvatarImageView;
@property (nonatomic, weak) IBOutlet UIImageView *quoteImageView;
@property (nonatomic, weak) IBOutlet UITextView *messageTextView;

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VSuggestedUsersDataSource *suggestedUsersDataSource;
@property (nonatomic, strong) VCreatorMessageViewController *creatorMessageViewController;

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
    
    BOOL stringIsValid = ownerName != nil && ownerName.length > 0;
    BOOL profileImageURLIsEmpty = [profileImageURL.absoluteString isEqualToString:@""];
    if ( !stringIsValid || profileImageURLIsEmpty )
    {
        self.creatorNameLabel.text = ownerName;
        self.creatorNameLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeading1FontKey];
        self.creatorNameLabel.textColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryTextColorKey];
        
        self.quoteImageView.image = [self.quoteImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.quoteImageView.tintColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    }
    else
    {
        self.creatorNameLabel.hidden = YES;
        self.creatorAvatarImageView.hidden = YES;
        self.salutationContainerHeight.constant = 0.0;
    }
    
    self.messageTextView.text = @"Come join our community. \
    We promise that your information is safe with us! \
    Come join our community."; //[self.dependencyManager stringForKey:VSuggestedUsersPromptKey];
    self.messageTextView.font = [self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
    self.messageTextView.textColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.suggestedUsersDataSource = [[VSuggestedUsersDataSource alloc] initWithDependencyManager:self.dependencyManager];
    [self.suggestedUsersDataSource registerCellsForCollectionView:self.collectionView];
    self.collectionView.dataSource = self.suggestedUsersDataSource;
    
    __weak typeof(self) welf = self;
    [self.activityIndicator startAnimating];
    [self.suggestedUsersDataSource refreshWithCompletion:^
    {
        [welf suggestedUsersDidLoad];
    }];
    
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
    return UIEdgeInsetsMake( 20.0f, 0, 10.0f, 0 );
}

@end
