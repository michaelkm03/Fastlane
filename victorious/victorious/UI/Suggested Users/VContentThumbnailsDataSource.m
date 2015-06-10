//
//  VContentThumbnailsDataSource.m
//  victorious
//
//  Created by Patrick Lynch on 6/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VContentThumbnailsDataSource.h"
#import "VSequence.h"
#import "VContentThumbnailCell.h"

@interface VContentThumbnailsDataSource()

@property (nonatomic, strong) NSArray *sequences;

@end

@implementation VContentThumbnailsDataSource

#pragma mark - UICollectionViewDataSource

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    NSString *identifier = [VContentThumbnailCell preferredReuseIdentifier];
    UINib *nib = [UINib nibWithNibName:identifier bundle:[NSBundle bundleForClass:[self class]]];
    [collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [VContentThumbnailCell preferredReuseIdentifier];
    VContentThumbnailCell *cell = (VContentThumbnailCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if ( cell != nil )
    {
        cell.backgroundColor = [UIColor orangeColor];
        return cell;
    }
    
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10;
}

@end
