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
#import "VUser.h"

@interface VContentThumbnailsDataSource()

@property (nonatomic, strong) VUser *user;

@end

@implementation VContentThumbnailsDataSource

#pragma mark - UICollectionViewDataSource

- (instancetype)initWithUser:(VUser *)user
{
    self = [super init];
    if ( self != nil )
    {
        _user = user;
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
        VSequence *sequence = self.user.recentSequences.array[ indexPath.row ];
        NSURL *previewURL = [NSURL URLWithString:sequence.previewData];
        [cell setImageURL:previewURL];
        return cell;
    }
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.user.recentSequences.count;
}

@end
