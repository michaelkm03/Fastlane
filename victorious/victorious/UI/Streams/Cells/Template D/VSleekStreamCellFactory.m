//
//  VSleekStreamCellFactory.m
//  victorious
//
//  Created by Sharif Ahmed on 3/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSleekStreamCellFactory.h"
#import "VSleekStreamCollectionCell.h"
#import "VSleekStreamCollectionCellPoll.h"
#import "VSequence+Fetcher.h"
#import "VStreamCollectionCellWebContent.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VNoContentCollectionViewCellProvider.h"

@interface VSleekStreamCellFactory ()

@property (nonatomic, readonly) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VNoContentCollectionViewCellProvider *noContentCollectionViewCellProvider;

@end

@implementation VSleekStreamCellFactory

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
        _noContentCollectionViewCellProvider = [[VNoContentCollectionViewCellProvider alloc] initWithAcceptableContentClasses:@[[VSequence class]]];
    }
    return self;
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[VSleekStreamCollectionCell nibForCell] forCellWithReuseIdentifier:[VSleekStreamCollectionCell suggestedReuseIdentifier]];
    [collectionView registerNib:[VSleekStreamCollectionCellPoll nibForCell] forCellWithReuseIdentifier:[VSleekStreamCollectionCellPoll suggestedReuseIdentifier]];
    [collectionView registerNib:[VStreamCollectionCellWebContent nibForCell] forCellWithReuseIdentifier:[VStreamCollectionCellWebContent suggestedReuseIdentifier]];
    [self.noContentCollectionViewCellProvider registerNoContentCellWithCollectionView:collectionView];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForStreamItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)indexPath
{
    if ( [self.noContentCollectionViewCellProvider shouldDisplayNoContentCellForContentClass:[streamItem class]] )
    {
        return [self.noContentCollectionViewCellProvider noContentCellForCollectionView:collectionView atIndexPath:indexPath];
    }
    
    VSequence *sequence = (VSequence *)streamItem;
    VStreamCollectionCell *cell;
    
    if ( [sequence isPoll] )
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VSleekStreamCollectionCellPoll suggestedReuseIdentifier]
                                                         forIndexPath:indexPath];
    }
    else if ([sequence isPreviewWebContent])
    {
        NSString *identifier = [VStreamCollectionCellWebContent suggestedReuseIdentifier];
        VStreamCollectionCellWebContent *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                          forIndexPath:indexPath];
        cell.sequence = sequence;
        [self.dependencyManager addLoadingBackgroundToBackgroundHost:cell];
        return cell;
    }
    else
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VSleekStreamCollectionCell suggestedReuseIdentifier]
                                                         forIndexPath:indexPath];
    }
    cell.dependencyManager = self.dependencyManager;
    cell.sequence = sequence;
    [self.dependencyManager addLoadingBackgroundToBackgroundHost:cell];
    
    return cell;
}

- (CGSize)sizeWithCollectionViewBounds:(CGRect)bounds ofCellForStreamItem:(VStreamItem *)streamItem
{
    if ( [self.noContentCollectionViewCellProvider shouldDisplayNoContentCellForContentClass:[streamItem class]] )
    {
        return [self.noContentCollectionViewCellProvider cellSizeForCollectionViewBounds:bounds];
    }
    
    VSequence *sequence = (VSequence *)streamItem;
    
    if ( [sequence isPoll] )
    {
        return [VSleekStreamCollectionCellPoll actualSizeWithCollectionViewBounds:bounds sequence:sequence dependencyManager:self.dependencyManager];
    }
    else
    {
        return [VSleekStreamCollectionCell actualSizeWithCollectionViewBounds:bounds sequence:sequence dependencyManager:self.dependencyManager];
    }
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
