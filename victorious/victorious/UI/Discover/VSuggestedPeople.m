//
//  VSuggestedPeople.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSuggestedPeople.h"
#import "VSuggestedPersonCollectionViewCell.h"

static NSString * const kSuggestedPersonCellIdentifier = @"VSuggestedPersonCollectionViewCell";

@interface VSuggestedPeople ()

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *suggestedPeople;

@end

@implementation VSuggestedPeople

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
{
    self = [super init];
    if (self)
    {
        self.suggestedPeople = @[ @"Michael", @"Josh", @"Lawrence", @"Will", @"Patrick" ];
        
        self.collectionView = collectionView;
    }
    return self;
}

- (void)setCollectionView:(UICollectionView *)collectionView
{
    _collectionView = collectionView;
    [self configureCollectionView:self.collectionView];
}

- (void)configureCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[UINib nibWithNibName:kSuggestedPersonCellIdentifier bundle:nil] forCellWithReuseIdentifier:kSuggestedPersonCellIdentifier];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.suggestedPeople.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VSuggestedPersonCollectionViewCell *cell = (VSuggestedPersonCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kSuggestedPersonCellIdentifier forIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
