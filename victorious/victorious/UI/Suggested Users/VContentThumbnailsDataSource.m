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

- (instancetype)init
{
    self = [super init];
    if ( self != nil )
    {
        _sequences = @[ @"http://media-dev-public.s3-website-us-west-1.amazonaws.com/35c8f250240c9fbe6720f3d931028560.jpg",
                        @"http://media-dev-public.s3-website-us-west-1.amazonaws.com/5eaa665d637e71d63948b7981834d87a/640x640.jpg",
                        @"http://media-dev-public.s3-website-us-west-1.amazonaws.com/296608a4541efe0b03c0fc5ff01bab40.jpg",
                        @"http://media-dev-public.s3-website-us-west-1.amazonaws.com/20ac5446ccd935df7d7abc94544cb881/640x640.jpg",
                        @"http://media-dev-public.s3-website-us-west-1.amazonaws.com/5eaa665d637e71d63948b7981834d87a/640x640.jpg" ];
    }
    return self;
}

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
        NSString *url = self.sequences[ indexPath.row ];
        [cell setImageURL:[NSURL URLWithString:url]];
        return cell;
    }
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1 + arc4random() % self.sequences.count;
}

@end
