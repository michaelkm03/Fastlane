//
//  VInsetStreamCellFactory.m
//  victorious
//
//  Created by Josh Hinman on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInsetStreamCellFactory.h"
#import "VInsetStreamCollectionCell.h"
#import "VInsetStreamCollectionCellPoll.h"
#import "VSequence+Fetcher.h"
#import "VStreamCollectionCellWebContent.h"
#import "VDependencyManager.h"

// Background
#import "VDependencyManager+VBackground.h"
#import "VBackground.h"
#import "UIView+AutoLayout.h"

@interface VInsetStreamCellFactory ()

@property (nonatomic, readonly) VDependencyManager *dependencyManager;

@end

@implementation VInsetStreamCellFactory

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
    [collectionView registerNib:[VInsetStreamCollectionCell nibForCell] forCellWithReuseIdentifier:[VInsetStreamCollectionCell suggestedReuseIdentifier]];
    [collectionView registerNib:[VInsetStreamCollectionCellPoll nibForCell] forCellWithReuseIdentifier:[VInsetStreamCollectionCellPoll suggestedReuseIdentifier]];
    [collectionView registerNib:[VStreamCollectionCellWebContent nibForCell] forCellWithReuseIdentifier:[VStreamCollectionCellWebContent suggestedReuseIdentifier]];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForStreamItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)indexPath
{
    NSAssert( [streamItem isKindOfClass:[VSequence class]], @"This factory can only handle VSequence objects" );

    VSequence *sequence = (VSequence *)streamItem;
    VStreamCollectionCell *cell;
    
    if ( [sequence isPoll] )
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VInsetStreamCollectionCellPoll suggestedReuseIdentifier]
                                                         forIndexPath:indexPath];
    }
    else if ([sequence isPreviewWebContent])
    {
        NSString *identifier = [VStreamCollectionCellWebContent suggestedReuseIdentifier];
        VStreamCollectionCellWebContent *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                          forIndexPath:indexPath];
        cell.sequence = sequence;
        [self configureBackgroundOfCell:cell];
        return cell;
    }
    else
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VInsetStreamCollectionCell suggestedReuseIdentifier]
                                                         forIndexPath:indexPath];
    }
    cell.dependencyManager = self.dependencyManager;
    cell.sequence = sequence;
    
    [self configureBackgroundOfCell:cell];
    
    return cell;
}

- (CGSize)sizeWithCollectionViewBounds:(CGRect)bounds ofCellForStreamItem:(VStreamItem *)streamItem
{
    NSAssert( [streamItem isKindOfClass:[VSequence class]], @"This factory can only handle VSequence objects" );
    VSequence *sequence = (VSequence *)streamItem;

    if ( [sequence isPoll] )
    {
        return [VInsetStreamCollectionCellPoll actualSizeWithCollectionViewBounds:bounds sequence:sequence dependencyManager:self.dependencyManager];
    }
    else
    {
        return [VInsetStreamCollectionCell actualSizeWithCollectionViewBounds:bounds sequence:sequence dependencyManager:self.dependencyManager];
    }
}

- (CGFloat)minimumLineSpacing
{
    return 8.0f;
}

- (UIEdgeInsets)sectionInsets
{
    return UIEdgeInsetsMake(10.0f, 0.0f, 10.0f, 0.0f);
}

#pragma mark - Private

- (void)configureBackgroundOfCell:(VBaseCollectionViewCell *)cell
{
    if (![cell respondsToSelector:@selector(v_backgroundHost)])
    {
        return;
    }
    
    UIView *backgroundHost = [cell v_backgroundHost];
    
    if (backgroundHost.subviews.count > 0)
    {
        // We've already setup the background
        return;
    }
    
    VBackground *backgroundForCell = [self.dependencyManager background];
    if (backgroundForCell != nil)
    {
        UIView *backgroundView = [backgroundForCell viewForBackground];
        backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [backgroundHost addSubview:backgroundView];
        [backgroundHost v_addFitToParentConstraintsToSubview:backgroundView];
    }
}

@end
