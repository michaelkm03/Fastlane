//
//  VSuggestedUsersViewController.m
//  victorious
//
//  Created by Patrick Lynch on 6/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSuggestedUsersViewController.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "UIView+AutoLayout.h"
#import "VSuggestedUsersDataSource.h"
#import "VSuggestedUsersResponder.h"

@interface VSuggestedUsersViewController () <VBackgroundContainer, UICollectionViewDelegateFlowLayout, VSuggestedUsersResponder>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) VSuggestedUsersDataSource *suggestedUsersDataSource;

@end

@implementation VSuggestedUsersViewController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
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
    
    UICollectionViewLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.suggestedUsersDataSource = [[VSuggestedUsersDataSource alloc] initWithDependencyManager:self.dependencyManager];
    [self.suggestedUsersDataSource registerCellsForCollectionView:self.collectionView];
    self.collectionView.dataSource = self.suggestedUsersDataSource;
    [self.view addSubview:self.collectionView];
    [self.view v_addFitToParentConstraintsToSubview:self.collectionView];
    [self.suggestedUsersDataSource refreshWithCompletion:^
    {
        [self.collectionView reloadData];
    }];
    
    self.collectionView.contentInset = UIEdgeInsetsMake( 20.0f, 0, 10.0f, 0 );
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

#pragma mark - VSuggestedUsersResponder

- (void)onSuggestedUsersContinue
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
