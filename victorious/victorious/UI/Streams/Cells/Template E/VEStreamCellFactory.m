//
//  VEStreamCellFactory.m
//  victorious
//
//  Created by Michael Sena on 4/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEStreamCellFactory.h"

// Dependencies
#import "VDependencyManager+VBackgroundContainer.h"

// Models
#import "VSequence+Fetcher.h"

// Cells
#import "VEStreamCollectionViewCell.h"
#import "VStreamCollectionCellWebContent.h"

@interface VEStreamCellFactory ()

@property (nonatomic, readonly) VDependencyManager *dependencyManager;

@end

@implementation VEStreamCellFactory

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerClass:[VEStreamCollectionViewCell class]
       forCellWithReuseIdentifier:[VEStreamCollectionViewCell suggestedReuseIdentifier]];
    [collectionView registerNib:[VStreamCollectionCellWebContent nibForCell]
     forCellWithReuseIdentifier:[VStreamCollectionCellWebContent suggestedReuseIdentifier]];
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
                        withStreamItems:(NSArray *)streamItems
{
    for (VStreamItem *streamItem in streamItems)
    {
        NSAssert( [streamItem isKindOfClass:[VSequence class]], @"This factory can only handle VSequence objects" );
        
        VSequence *sequence = (VSequence *)streamItem;
        
        if ([sequence isPreviewWebContent])
        {
            [collectionView registerNib:[VStreamCollectionCellWebContent nibForCell]
             forCellWithReuseIdentifier:[VStreamCollectionCellWebContent suggestedReuseIdentifier]];
        }
        else
        {
            [collectionView registerClass:[VEStreamCollectionViewCell class]
               forCellWithReuseIdentifier:[VEStreamCollectionViewCell reuseIdentifierForSequence:sequence]];
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                       cellForStreamItem:(VStreamItem *)streamItem
                             atIndexPath:(NSIndexPath *)indexPath
{
    NSAssert( [streamItem isKindOfClass:[VSequence class]], @"This factory can only handle VSequence objects" );
    
    VSequence *sequence = (VSequence *)streamItem;
    UICollectionViewCell *cell;
    
    if ([sequence isPreviewWebContent])
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VStreamCollectionCellWebContent suggestedReuseIdentifier]
                                                         forIndexPath:indexPath];
        VStreamCollectionCellWebContent *webCell = (VStreamCollectionCellWebContent *)cell;
        webCell.sequence = sequence;
    }
    else
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VEStreamCollectionViewCell reuseIdentifierForSequence:sequence]
                                                         forIndexPath:indexPath];
    }

    if ([cell respondsToSelector:@selector(setDependencyManager:)])
    {
        [((id <VHasManagedDependencies>)cell) setDependencyManager:self.dependencyManager];
    }
    
    if ([cell conformsToProtocol:@protocol(VBackgroundContainer)])
    {
        [self.dependencyManager addLoadingBackgroundToBackgroundHost:(id <VBackgroundContainer>)cell];
        [self.dependencyManager addBackgroundToBackgroundHost:(id <VBackgroundContainer>)cell];
    }
    
    if ([cell isKindOfClass:[VEStreamCollectionViewCell class]])
    {
        VEStreamCollectionViewCell *eCollectionViewCell = (VEStreamCollectionViewCell *)cell;
        eCollectionViewCell.sequence = sequence;
    }
    
    return cell;
}

- (CGFloat)minimumLineSpacing
{
    return 17.5f;
}

- (CGSize)sizeWithCollectionViewBounds:(CGRect)bounds ofCellForStreamItem:(VStreamItem *)streamItem
{
    return CGSizeMake(CGRectGetWidth(bounds), CGRectGetWidth(bounds) + 75);
}

- (UIEdgeInsets)sectionInsets
{
    return UIEdgeInsetsZero;
}

@end
