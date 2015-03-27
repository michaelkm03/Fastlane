//
//  VTitleOverlayStreamCellFactory.m
//  victorious
//
//  Created by Josh Hinman on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSequence+Fetcher.h"
#import "VStreamCollectionCell.h"
#import "VStreamCollectionCellPoll.h"
#import "VStreamCollectionCellWebContent.h"
#import "VTitleOverlayStreamCellFactory.h"
#import "VDependencyManager+VBackgroundHost.h"
#import "VBackground.h"
#import "UIView+AutoLayout.h"

@interface VTitleOverlayStreamCellFactory ()

@property (nonatomic, readonly) VDependencyManager *dependencyManager;

@end

@implementation VTitleOverlayStreamCellFactory

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[VStreamCollectionCell nibForCell] forCellWithReuseIdentifier:[VStreamCollectionCell suggestedReuseIdentifier]];
    [collectionView registerNib:[VStreamCollectionCellPoll nibForCell] forCellWithReuseIdentifier:[VStreamCollectionCellPoll suggestedReuseIdentifier]];
    [collectionView registerNib:[VStreamCollectionCellWebContent nibForCell] forCellWithReuseIdentifier:[VStreamCollectionCellWebContent suggestedReuseIdentifier]];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForStreamItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)indexPath
{
    NSAssert( [streamItem isKindOfClass:[VSequence class]], @"This factory can only handle VSequence objects" );
    
    VSequence *sequence = (VSequence *)streamItem;
    VStreamCollectionCell *cell;
    
    if ( [sequence isPoll] )
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VStreamCollectionCellPoll suggestedReuseIdentifier]
                                                         forIndexPath:indexPath];
    }
    else if ([sequence isPreviewWebContent])
    {
        NSString *identifier = [VStreamCollectionCellWebContent suggestedReuseIdentifier];
        VStreamCollectionCellWebContent *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                          forIndexPath:indexPath];
        cell.sequence = sequence;
        [self.dependencyManager addBackgroundToBackgroundHost:cell];
        return cell;
    }
    else
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VStreamCollectionCell suggestedReuseIdentifier]
                                                         forIndexPath:indexPath];
    }
    cell.dependencyManager = self.dependencyManager;
    cell.sequence = sequence;
    [self.dependencyManager addBackgroundToBackgroundHost:cell];
    
    return cell;
}

- (CGSize)sizeWithCollectionViewBounds:(CGRect)bounds ofCellForStreamItem:(VStreamItem *)streamItem
{
    NSAssert( [streamItem isKindOfClass:[VSequence class]], @"This factory can only handle VSequence objects" );
    VSequence *sequence = (VSequence *)streamItem;
    
    if ([sequence isPoll])
    {
        return [VStreamCollectionCellPoll desiredSizeWithCollectionViewBounds:bounds];
    }
    else
    {
        return [VStreamCollectionCell desiredSizeWithCollectionViewBounds:bounds];
    }
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
