//
//  VSuggesedUsersDataSource.m
//  victorious
//
//  Created by Patrick Lynch on 6/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSuggestedUsersDataSource.h"
#import "VSuggestedUserCell.h"
#import "VSuggestedUsersHeaderCell.h"
#import "VObjectManager+Discover.h"
#import "VDependencyManager.h"
#import "VUser.h"
#import "VFollowResponder.h"

@interface VSuggestedUsersDataSource()

@property (nonatomic, strong) NSArray *suggestedUsers;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

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
    NSString *identifier = [VSuggestedUserCell suggestedReuseIdentifier];
    UINib *nib = [UINib nibWithNibName:identifier bundle:[NSBundle bundleForClass:[self class]]];
    [collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
    
    identifier = [VSuggestedUsersHeaderCell suggestedReuseIdentifier];
    nib = [UINib nibWithNibName:identifier bundle:[NSBundle bundleForClass:[self class]]];
    [collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}

- (void)refreshWithCompletion:(void(^)())completion
{
    [[VObjectManager sharedManager] getSuggestedUsers:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         self.suggestedUsers = resultObjects;
         if ( completion != nil )
         {
             completion();
         }
     } failBlock:^(NSOperation *operation, NSError *error)
     {
         // TODO: Error message!
     }];
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 0 )
    {
        return CGSizeMake( CGRectGetWidth(collectionView.bounds), 160.0f );
    }
    else
    {
        return CGSizeMake( CGRectGetWidth(collectionView.bounds) - 20.0f, 140.0f );
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return section == 0 ? 1 : self.suggestedUsers.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 0 )
    {
        NSString *identifier = [VSuggestedUsersHeaderCell suggestedReuseIdentifier];
        VSuggestedUsersHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                    forIndexPath:indexPath];
        if ( cell != nil )
        {
            [cell setDependencyManager:self.dependencyManager];
            [cell setMessage:@"FUCK"];
            return cell;
        }
    }
    else
    {
        NSString *identifier = [VSuggestedUserCell suggestedReuseIdentifier];
        VSuggestedUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                             forIndexPath:indexPath];
        if ( cell != nil )
        {
            cell.dependencyManager = self.dependencyManager;
            VUser *user = self.suggestedUsers[ indexPath.row ];
            [cell setUser:user];
            return cell;
        }
    }
    return nil;
}

@end
