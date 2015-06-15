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
#import "VSuggestedUsersResponder.h"
#import "VCreatorMessageViewController.h"
#import "UIView+AutoLayout.h"
#import "VLoginFlowControllerDelegate.h"

static NSString * const kBarButtonTintColorKey = @"color.text.label3";

@interface VSuggestedUsersViewController () <VBackgroundContainer, UICollectionViewDelegateFlowLayout, VLoginFlowScreen>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIView *creatorMessageContainer;
@property (nonatomic, weak) IBOutlet UIView *collectionContainer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *creatorMessageContainerHeight;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

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
    
    NSDictionary *mapping = @{ VDependencyManagerHeading3FontKey : [self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey],
                               VDependencyManagerLabel1FontKey : [self.dependencyManager fontForKey:VDependencyManagerHeading1FontKey],
                               VDependencyManagerMainTextColorKey : [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey],
                               VDependencyManagerSecondaryTextColorKey : [self.dependencyManager colorForKey:VDependencyManagerSecondaryTextColorKey] };
    VDependencyManager *creatorMessageComponent = [self.dependencyManager childDependencyManagerWithAddedConfiguration:mapping];
    self.creatorMessageViewController = [[VCreatorMessageViewController alloc] initWithDependencyManager:creatorMessageComponent];
    [self.creatorMessageViewController setMessage:[self.dependencyManager stringForKey:@"prompt"]];
    [self.creatorMessageContainer addSubview:self.creatorMessageViewController.view];
    [self.creatorMessageContainer v_addFitToParentConstraintsToSubview:self.creatorMessageViewController.view];
    self.creatorMessageContainerHeight.constant = CGRectGetHeight(self.creatorMessageViewController.view.bounds);
    [self.creatorMessageContainer layoutIfNeeded];
    
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
    
    self.collectionView.contentInset = UIEdgeInsetsMake( 20.0f, 0, 10.0f, 0 );
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    UIImage *emptyImage = [[UIImage alloc] init];
    [self.navigationController.navigationBar setBackgroundImage:emptyImage forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = emptyImage;
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    self.collectionView.transform = CGAffineTransformMakeTranslation( 0, CGRectGetHeight(self.collectionView.frame));
    
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
         } completion:nil];
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

@end
