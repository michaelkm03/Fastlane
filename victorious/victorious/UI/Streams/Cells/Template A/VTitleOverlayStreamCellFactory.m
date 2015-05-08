//
//  VTitleOverlayStreamCellFactory.m
//  victorious
//
//  Created by Josh Hinman on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTitleOverlayStreamCellFactory.h"

// Models + Helpers
#import "VSequence+Fetcher.h"

#import "VDependencyManager+VBackgroundContainer.h"
#import "VNoContentCollectionViewCellFactory.h"
#import "VTileOverlayCollectionCell.h"

@interface VTitleOverlayStreamCellFactory ()

@property (nonatomic, readonly) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VNoContentCollectionViewCellFactory *noContentCollectionViewCellFactory;

@end

@implementation VTitleOverlayStreamCellFactory

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
        _noContentCollectionViewCellFactory = [[VNoContentCollectionViewCellFactory alloc] initWithAcceptableContentClasses:@[[VSequence class]]];
    }
    return self;
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerClass:[VTileOverlayCollectionCell class]
       forCellWithReuseIdentifier:[VTileOverlayCollectionCell suggestedReuseIdentifier]];
    [self.noContentCollectionViewCellFactory registerNoContentCellWithCollectionView:collectionView];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForStreamItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)indexPath
{
    if ( [self.noContentCollectionViewCellFactory shouldDisplayNoContentCellForContentClass:[streamItem class]] )
    {
        return [self.noContentCollectionViewCellFactory noContentCellForCollectionView:collectionView atIndexPath:indexPath];
    }
    
    VSequence *sequence = (VSequence *)streamItem;

    VTileOverlayCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VTileOverlayCollectionCell suggestedReuseIdentifier]
                                                                                 forIndexPath:indexPath];
    cell.dependencyManager = self.dependencyManager;
    cell.sequence = sequence;
    [self.dependencyManager addLoadingBackgroundToBackgroundHost:cell];
    
    return cell;
}

- (CGSize)sizeWithCollectionViewBounds:(CGRect)bounds ofCellForStreamItem:(VStreamItem *)streamItem
{
    return [VTileOverlayCollectionCell actualSizeWithCollectionViewBounds:bounds
                                                                 sequence:(VSequence *)streamItem
                                                        dependencyManager:self.dependencyManager];
}

- (CGFloat)minimumLineSpacing
{
    return 0;
}

- (UIEdgeInsets)sectionInsets
{
    return UIEdgeInsetsZero;
}

@end
