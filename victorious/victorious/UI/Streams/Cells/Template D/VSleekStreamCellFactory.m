//
//  VSleekStreamCellFactory.m
//  victorious
//
//  Created by Sharif Ahmed on 3/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSleekStreamCellFactory.h"
#import "VSleekStreamCollectionCell.h"
#import "VSequence+Fetcher.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VNoContentCollectionViewCellFactory.h"
#import "VDependencyManager+VHighlightContainer.h"
#import "victorious-Swift.h"

@interface VSleekStreamCellFactory ()

@property (nonatomic, readonly) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VNoContentCollectionViewCellFactory *noContentCollectionViewCellFactory;
@property (nonatomic, strong) NSMutableSet *registeredReuseIdentifiers;

@end

@implementation VSleekStreamCellFactory

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
        _noContentCollectionViewCellFactory = [[VNoContentCollectionViewCellFactory alloc] initWithAcceptableContentClasses:@[[VSequence class]]];
        _registeredReuseIdentifiers = [[NSMutableSet alloc] init];
    }
    return self;
}

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[VSleekStreamCollectionCell nibForCell] forCellWithReuseIdentifier:[VSleekStreamCollectionCell suggestedReuseIdentifier]];
    [self.noContentCollectionViewCellFactory registerNoContentCellWithCollectionView:collectionView];
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
                        withStreamItems:(NSArray *)streamItems
{
    for (VStreamItem *streamItem in streamItems)
    {
        NSString *reuseIdentifierForSequence = [VSleekStreamCollectionCell reuseIdentifierForStreamItem:streamItem
                                                                                         baseIdentifier:@""
                                                                                      dependencyManager:self.dependencyManager];
        
        if (![self.registeredReuseIdentifiers containsObject:reuseIdentifierForSequence])
        {
            [collectionView registerNib:[VSleekStreamCollectionCell nibForCell]
             forCellWithReuseIdentifier:reuseIdentifierForSequence];
            [self.registeredReuseIdentifiers addObject:reuseIdentifierForSequence];
        }
    }
    [self.noContentCollectionViewCellFactory registerNoContentCellWithCollectionView:collectionView];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForStreamItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)indexPath
{
    return [self collectionView:collectionView cellForStreamItem:streamItem atIndexPath:indexPath inStream:nil];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForStreamItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)indexPath inStream:(VStream *)stream
{
    if ( [self.noContentCollectionViewCellFactory shouldDisplayNoContentCellForContentClass:[streamItem class]] )
    {
        VLog(@"VSleekStreamCellFactory encountered an unsupported streamItem subclass and will display a no content cell");
        return [self.noContentCollectionViewCellFactory noContentCellForCollectionView:collectionView atIndexPath:indexPath];
    }
    
    VSequence *sequence = (VSequence *)streamItem;
    NSString *reuseIdentifierForSequence = [VSleekStreamCollectionCell reuseIdentifierForStreamItem:streamItem
                                                                                     baseIdentifier:@""
                                                                                  dependencyManager:self.dependencyManager];
    
    if (![self.registeredReuseIdentifiers containsObject:reuseIdentifierForSequence])
    {
        [collectionView registerNib:[VSleekStreamCollectionCell nibForCell]
         forCellWithReuseIdentifier:reuseIdentifierForSequence];
        [self.registeredReuseIdentifiers addObject:reuseIdentifierForSequence];
    }
    
    StreamCellContext *context = [[StreamCellContext alloc] initWithStreamItem:streamItem stream:stream fromShelf:NO];
    
    VSleekStreamCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierForSequence
                                                                                 forIndexPath:indexPath];
    cell.accessibilityIdentifier = VAutomationIdentifierStreamCell;
    cell.dependencyManager = self.dependencyManager;
    cell.sequence = sequence;
    cell.stream = stream;
    cell.context = context;
    [self.dependencyManager addLoadingBackgroundToBackgroundHost:cell];
    [self.dependencyManager addBackgroundToBackgroundHost:cell];
    [self.dependencyManager addHighlightViewToHost:cell];
    
    return cell;
}

- (CGSize)sizeWithCollectionViewBounds:(CGRect)bounds ofCellForStreamItem:(VStreamItem *)streamItem
{
    if ( [self.noContentCollectionViewCellFactory shouldDisplayNoContentCellForContentClass:[streamItem class]] )
    {
        return [self.noContentCollectionViewCellFactory cellSizeForCollectionViewBounds:bounds];
    }
    
    VSequence *sequence = (VSequence *)streamItem;
    return [VSleekStreamCollectionCell actualSizeWithCollectionViewBounds:bounds
                                                                 sequence:sequence
                                                        dependencyManager:self.dependencyManager];
}

- (CGFloat)minimumLineSpacing
{
    return 1.0f;
}

- (UIEdgeInsets)sectionInsets
{
    return UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
}

- (void)updateVisibleCellsInCollectionView:(UICollectionView *)collectionView
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for ( UICollectionViewCell *cell in collectionView.visibleCells )
    {
        if ( [cell isKindOfClass:[VSleekStreamCollectionCell class]] )
        {
            VSleekStreamCollectionCell *sleekCell = (VSleekStreamCollectionCell *)cell;
            if ( sleekCell.needsRefresh )
            {
                [indexPaths addObject:[collectionView indexPathForCell:sleekCell]];
                [sleekCell purgeSizeCacheValue];
            }
        }
    }
    
    if ( indexPaths.count > 0 )
    {
        [collectionView reloadItemsAtIndexPaths:indexPaths];
    }
}

@end
