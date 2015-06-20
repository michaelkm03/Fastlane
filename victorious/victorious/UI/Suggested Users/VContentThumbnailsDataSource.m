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

@interface VContentThumbnailsDataSource()

@property (nonatomic, strong) NSArray *sequences;

@end

@implementation VContentThumbnailsDataSource

#pragma mark - UICollectionViewDataSource

- (instancetype)initWithSequences:(NSArray *)sequences
{
    NSParameterAssert( sequences != nil );
    self = [super init];
    if ( self != nil )
    {
        _sequences = sequences;
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
    NSString *identifier = [VContentThumbnailCell suggestedReuseIdentifier];
    VContentThumbnailCell *cell = (VContentThumbnailCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if ( cell != nil )
    {
        VSequence *sequence = self.sequences[ indexPath.row ];
        NSURL *previewURL = [NSURL URLWithString:sequence.previewData];
        [cell setImageURL:previewURL];
        return cell;
    }
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.sequences.count;
}

@end
