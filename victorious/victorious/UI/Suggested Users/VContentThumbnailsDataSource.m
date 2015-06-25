//
//  VContentThumbnailsDataSource.m
//  victorious
//
//  Created by Patrick Lynch on 6/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VContentThumbnailsDataSource.h"
#import "VSequence+Fetcher.h"
#import "VContentThumbnailCell.h"
#import "VImageAsset.h"
#import "VImageAssetFinder.h"
#import "UIImage+Resize.h"

@interface VContentThumbnailsDataSource()

@property (nonatomic, strong) NSArray *sequences;
@property (nonatomic, strong) VImageAssetFinder *assetFinder;

@end

@implementation VContentThumbnailsDataSource

#pragma mark - UICollectionViewDataSource

- (instancetype)initWithSequences:(NSArray *)sequences
{
    NSParameterAssert( sequences != nil );
    self = [super init];
    if ( self != nil )
    {
        
        _assetFinder = [[VImageAssetFinder alloc] init];
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(VSequence *sequence, NSDictionary *bindings)
                                  {
                                      VImageAsset *asset = [self.assetFinder smallestAssetFromAssets:sequence.previewAssets];
                                      return asset.imageURL.length > 0 && [NSURL URLWithString:asset.imageURL] != nil;
                                  }];
        _sequences = [sequences filteredArrayUsingPredicate:predicate];
    }
    return self;
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    NSString *identifier = [VContentThumbnailCell suggestedReuseIdentifier];
    UINib *nib = [UINib nibWithNibName:identifier bundle:[NSBundle bundleForClass:[self class]]];
    [collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<UICollectionViewDelegateFlowLayout> delegate = (id<UICollectionViewDelegateFlowLayout>)collectionView.delegate;
    CGSize cellSize = [delegate collectionView:collectionView layout:collectionView.collectionViewLayout sizeForItemAtIndexPath:indexPath];
    
    NSString *identifier = [VContentThumbnailCell suggestedReuseIdentifier];
    VContentThumbnailCell *cell = (VContentThumbnailCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if ( cell != nil )
    {
        VSequence *sequence = self.sequences[ indexPath.row ];
        VImageAsset *asset = [self.assetFinder assetWithPreferredMaximumSize:cellSize fromAssets:sequence.previewAssets];
        NSURL *imageURL = [NSURL URLWithString:asset.imageURL];
        [cell setImageURL:imageURL];
        return cell;
    }
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.sequences.count;
}

@end
