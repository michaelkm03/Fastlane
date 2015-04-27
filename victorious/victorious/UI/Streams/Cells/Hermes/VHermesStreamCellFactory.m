//
//  VHermesStreamCellFactory.m
//  victorious
//
//  Created by Michael Sena on 4/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHermesStreamCellFactory.h"

// Dependencies
#import "VDependencyManager+VBackgroundContainer.h"

// Models
#import "VSequence+Fetcher.h"

// Cells
#import "VHermesStreamCollectionViewCell.h"
#import "VStreamCollectionCellWebContent.h"

@interface VHermesStreamCellFactory ()

@property (nonatomic, readonly) VDependencyManager *dependencyManager;
@property (nonatomic, strong) NSMutableSet *registeredIdentifiers;

@end

@implementation VHermesStreamCellFactory

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
        _registeredIdentifiers = [[NSMutableSet alloc] init];
    }
    return self;
}

#pragma mark - VStreamCellFactory

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerClass:[VHermesStreamCollectionViewCell class]
       forCellWithReuseIdentifier:[VHermesStreamCollectionViewCell suggestedReuseIdentifier]];
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

        NSString *reuseIdentifier = nil;
        if ([sequence isPreviewWebContent])
        {
            reuseIdentifier = [VStreamCollectionCellWebContent suggestedReuseIdentifier];
            [collectionView registerNib:[VStreamCollectionCellWebContent nibForCell]
             forCellWithReuseIdentifier:reuseIdentifier];
        }
        else
        {
            reuseIdentifier = [VHermesStreamCollectionViewCell reuseIdentifierForSequence:sequence];
            [collectionView registerClass:[VHermesStreamCollectionViewCell class]
               forCellWithReuseIdentifier:reuseIdentifier];
        }
        [self.registeredIdentifiers addObject:reuseIdentifier];
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
        if (![self.registeredIdentifiers containsObject:[VHermesStreamCollectionViewCell reuseIdentifierForSequence:sequence]])
        {
            [self registerCellsWithCollectionView:collectionView
                                  withStreamItems:@[sequence]];
        }
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VHermesStreamCollectionViewCell reuseIdentifierForSequence:sequence]
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
    
    if ([cell isKindOfClass:[VHermesStreamCollectionViewCell class]])
    {
        VHermesStreamCollectionViewCell *eCollectionViewCell = (VHermesStreamCollectionViewCell *)cell;
        eCollectionViewCell.sequence = sequence;
    }
    
    return cell;
}

- (CGFloat)minimumLineSpacing
{
    return 0.0f;
}

- (CGSize)sizeWithCollectionViewBounds:(CGRect)bounds ofCellForStreamItem:(VStreamItem *)streamItem
{
    NSAssert( [streamItem isKindOfClass:[VSequence class]], @"This factory can only handle VSequence objects" );
    
    VSequence *sequence = (VSequence *)streamItem;

    return [VHermesStreamCollectionViewCell actualSizeWithCollectionViewBounds:bounds
                                                                      sequence:sequence
                                                             dependencyManager:self.dependencyManager];
}

- (UIEdgeInsets)sectionInsets
{
    return UIEdgeInsetsZero;
}

@end
