//
//  VSuggesedUsersDataSource.m
//  victorious
//
//  Created by Patrick Lynch on 6/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSuggestedUsersDataSource.h"
#import "VSuggestedUserCell.h"
#import "VDependencyManager.h"
#import "VSuggestedUserRetryCell.h"
#import "victorious-Swift.h"

static NSString * const kPromptTextKey = @"prompt";

@interface VSuggestedUsersDataSource()

@property (nonatomic, strong) NSArray *suggestedUsers;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, assign) NSOperation *currentLoadOperation;
@property (nonatomic, assign) BOOL loadedOnce;
@property (nonatomic, strong) VSuggestedUserRetryCell *retryCell;

@end

@implementation VSuggestedUsersDataSource

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (void)registerCellsForCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[VSuggestedUserCell nibForCell]
     forCellWithReuseIdentifier:[VSuggestedUserCell suggestedReuseIdentifier]];
    [collectionView registerNib:[VSuggestedUserRetryCell nibForCell]
     forCellWithReuseIdentifier:[VSuggestedUserRetryCell suggestedReuseIdentifier]];
}

- (void)refreshWithCompletion:(void(^)())completion
{
    if ( self.currentLoadOperation != nil )
    {
        //Already loading, don't try to load again
        return;
    }
    
    SuggestedUsersOperation *operation = [[SuggestedUsersOperation alloc] init];
    [operation queueWithCompletion:^(NSArray *_Nullable results, NSError *_Nullable error, BOOL cancelled)
    {
        NSArray<VSuggestedUser *> *suggestedUsers = operation.results;
        if ( error == nil && suggestedUsers != nil )
        {
            self.loadedOnce = YES;
            self.currentLoadOperation = nil;
            [self updateStateOfRetryCell];
            self.suggestedUsers = suggestedUsers;
            if ( completion != nil )
            {
                completion();
            }
        }
    }];
    
    self.currentLoadOperation = operation;
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake( CGRectGetWidth(collectionView.bounds) - 20.0f, 140.0f );
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ( self.isDisplayingRetryCell )
    {
        return 1;
    }
    return self.suggestedUsers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VBaseCollectionViewCell *cell;
    if ( self.isDisplayingRetryCell )
    {
        NSString *identifier = [VSuggestedUserRetryCell suggestedReuseIdentifier];
        if ( self.retryCell == nil )
        {
            VSuggestedUserRetryCell *suggestedUserRetryCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                                        forIndexPath:indexPath];
            suggestedUserRetryCell.dependencyManager = self.dependencyManager;
            self.retryCell = suggestedUserRetryCell;
        }
        cell = self.retryCell;
    }
    else
    {
        NSString *identifier = [VSuggestedUserCell suggestedReuseIdentifier];
        VSuggestedUserCell *suggestedUserCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                          forIndexPath:indexPath];
        suggestedUserCell.dependencyManager = self.dependencyManager;
        VSuggestedUser *suggestedUser = self.suggestedUsers[ indexPath.row ];
        [suggestedUserCell configureWithSuggestedUser:suggestedUser];
        cell = suggestedUserCell;
    }
    return cell;
}

#pragma mark - setters / getters

- (void)setRetryCell:(VSuggestedUserRetryCell *)retryCell
{
    _retryCell = retryCell;
    [self updateStateOfRetryCell];
}

- (BOOL)isDisplayingRetryCell
{
    return ( self.suggestedUsers == nil || self.suggestedUsers.count == 0 ) && self.loadedOnce;
}

#pragma mark - helpers

- (void)updateStateOfRetryCell
{
    self.retryCell.state = self.currentLoadOperation != nil ? VSuggestedUserRetryCellStateLoading : VSuggestedUserRetryCellStateDefault;
}

@end
