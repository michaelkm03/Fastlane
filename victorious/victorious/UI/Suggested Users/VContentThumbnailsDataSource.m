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
@property (nonatomic, strong) NSArray *DEBUG_imageUrls;

@end

@implementation VContentThumbnailsDataSource

#pragma mark - UICollectionViewDataSource

- (instancetype)initWithUser:(VUser *)user
{
    self = [super init];
    if ( self != nil )
    {
        _user = user;
        _DEBUG_imageUrls = @[ @"http://media-dev-public.s3-website-us-west-1.amazonaws.com/35c8f250240c9fbe6720f3d931028560.jpg",
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
        NSString *string = self.DEBUG_imageUrls[ indexPath.row ];
        [cell setImageURL:[NSURL URLWithString:string]];
        return cell;
        
        VSequence *sequence = self.user.postedSequences.array[ indexPath.row ];
        NSURL *previewURL = [NSURL URLWithString:sequence.previewData];
        [cell setImageURL:previewURL];
        return cell;
    }
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1 + arc4random() % self.DEBUG_imageUrls.count;
    return self.user.postedSequences.count;
}

@end
