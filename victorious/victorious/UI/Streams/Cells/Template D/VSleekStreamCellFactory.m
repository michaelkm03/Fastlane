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

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[VSleekStreamCollectionCell nibForCell] forCellWithReuseIdentifier:[VSleekStreamCollectionCell suggestedReuseIdentifier]];
    [self.noContentCollectionViewCellFactory registerNoContentCellWithCollectionView:collectionView];
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
                        withStreamItems:(NSArray *)streamItems
{
    for (VSequence *sequence in streamItems)
    {
        NSString *reuseIdentifierForSequence = [VSleekStreamCollectionCell reuseIdentifierForSequence:sequence baseIdentifier:@""];
        
        if (![self.registeredReuseIdentifiers containsObject:reuseIdentifierForSequence])
        {
            [collectionView registerNib:[VSleekStreamCollectionCell nibForCell]
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
    
    NSString *reuseIdentifierForSequence = [VSleekStreamCollectionCell reuseIdentifierForSequence:(VSequence *)streamItem
                                                                                   baseIdentifier:@""];
    VLog(@"%@", reuseIdentifierForSequence);
    
    if (![self.registeredReuseIdentifiers containsObject:reuseIdentifierForSequence])
    {
        [collectionView registerNib:[VSleekStreamCollectionCell nibForCell]
         forCellWithReuseIdentifier:reuseIdentifierForSequence];
        [self.registeredReuseIdentifiers addObject:reuseIdentifierForSequence];
    }
    
    VSequence *sequence = (VSequence *)streamItem;
    VSleekStreamCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierForSequence
                                                                                 forIndexPath:indexPath];
    cell.dependencyManager = self.dependencyManager;
    cell.sequence = sequence;
    [self.dependencyManager addLoadingBackgroundToBackgroundHost:cell];
    [self.dependencyManager addBackgroundToBackgroundHost:cell];
    
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

@end
