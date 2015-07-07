//
//  VInsetStreamCellFactory.m
//  victorious
//
//  Created by Josh Hinman on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInsetStreamCellFactory.h"
#import "VInsetStreamCollectionCell.h"
#import "VSequence+Fetcher.h"
#import "VDependencyManager.h"

// Background
#import "VDependencyManager+VBackgroundContainer.h"
#import "VBackground.h"
#import "UIView+AutoLayout.h"
#import "VNoContentCollectionViewCellFactory.h"

// Highlight
#import "VDependencyManager+VHighlightContainer.h"

@interface VInsetStreamCellFactory ()

@property (nonatomic, readonly) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VNoContentCollectionViewCellFactory *noContentCollectionViewCellFactory;
@property (nonatomic, strong) NSMutableSet *registeredReuseIdentifiers;

@end

@implementation VInsetStreamCellFactory

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

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    [self.noContentCollectionViewCellFactory registerNoContentCellWithCollectionView:collectionView];
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView withStreamItems:(NSArray *)streamItems
{
    for (VStreamItem *streamItem in streamItems)
    {
        if (![streamItem isKindOfClass:[VSequence class]])
        {
            NSAssert(false, @"This factory can only handle sequences.");
        }        
        NSString *reuseIdentifierForSequence = [VInsetStreamCollectionCell reuseIdentifierForStreamItem:streamItem
                                                                                         baseIdentifier:@""
                                                                                      dependencyManager:self.dependencyManager];
        
        if (![self.registeredReuseIdentifiers containsObject:reuseIdentifierForSequence])
        {
            [collectionView registerClass:[VInsetStreamCollectionCell class]
               forCellWithReuseIdentifier:reuseIdentifierForSequence];
            [self.registeredReuseIdentifiers addObject:reuseIdentifierForSequence];
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForStreamItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)indexPath
{
    if ( [self.noContentCollectionViewCellFactory shouldDisplayNoContentCellForContentClass:[streamItem class]] )
    {
        return [self.noContentCollectionViewCellFactory noContentCellForCollectionView:collectionView atIndexPath:indexPath];
    }
    
    VSequence *sequence = (VSequence *)streamItem;
    NSString *reuseIdentifierForSequence = [VInsetStreamCollectionCell reuseIdentifierForStreamItem:streamItem
                                                                                   baseIdentifier:@""
                                                                                  dependencyManager:self.dependencyManager];
    
    if (![self.registeredReuseIdentifiers containsObject:reuseIdentifierForSequence])
    {
        [collectionView registerClass:[VInsetStreamCollectionCell class]
           forCellWithReuseIdentifier:reuseIdentifierForSequence];
        [self.registeredReuseIdentifiers addObject:reuseIdentifierForSequence];
    }

    VInsetStreamCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierForSequence
                                                                                 forIndexPath:indexPath];
    cell.dependencyManager = self.dependencyManager;
    cell.sequence = sequence;
    [self.dependencyManager addLoadingBackgroundToBackgroundHost:cell];
    [self.dependencyManager addBackgroundToBackgroundHost:cell];
    [self.dependencyManager addHighlightViewToHost:cell];
    
    return cell;
}

- (CGSize)sizeWithCollectionViewBounds:(CGRect)bounds ofCellForStreamItem:(VStreamItem *)streamItem
{
    UIEdgeInsets edgeInsets = [self sectionInsets];
    bounds.size.width -= edgeInsets.left + edgeInsets.right;
    if ( [self.noContentCollectionViewCellFactory shouldDisplayNoContentCellForContentClass:[streamItem class]] )
    {
        return [self.noContentCollectionViewCellFactory cellSizeForCollectionViewBounds:bounds];
    }
    
    VSequence *sequence = (VSequence *)streamItem;

    return [VInsetStreamCollectionCell actualSizeWithCollectionViewBounds:bounds
                                                                 sequence:sequence
                                                        dependencyManager:self.dependencyManager];
}

- (CGFloat)minimumLineSpacing
{
    return 8.0f;
}

- (UIEdgeInsets)sectionInsets
{
    return UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
}

@end
