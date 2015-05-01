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
#import "VDependencyManager+VBackgroundContainer.h"
#import "VBackground.h"
#import "UIView+AutoLayout.h"
#import "VNoContentCollectionViewCellFactory.h"

@interface VInsetStreamCellFactory ()

@property (nonatomic, readonly) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VNoContentCollectionViewCellFactory *noContentCollectionViewCellFactory;

@end

@implementation VInsetStreamCellFactory

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
    [collectionView registerNib:[VInsetStreamCollectionCell nibForCell] forCellWithReuseIdentifier:[VInsetStreamCollectionCell suggestedReuseIdentifier]];
    [collectionView registerNib:[VInsetStreamCollectionCellPoll nibForCell] forCellWithReuseIdentifier:[VInsetStreamCollectionCellPoll suggestedReuseIdentifier]];
    [collectionView registerNib:[VStreamCollectionCellWebContent nibForCell] forCellWithReuseIdentifier:[VStreamCollectionCellWebContent suggestedReuseIdentifier]];
    [self.noContentCollectionViewCellFactory registerNoContentCellWithCollectionView:collectionView];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForStreamItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)indexPath
{
    if ( [self.noContentCollectionViewCellFactory shouldDisplayNoContentCellForContentClass:[streamItem class]] )
    {
        return [self.noContentCollectionViewCellFactory noContentCellForCollectionView:collectionView atIndexPath:indexPath];
    }
    
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
        [self.dependencyManager addLoadingBackgroundToBackgroundHost:cell];
        return cell;
    }
    else
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VInsetStreamCollectionCell suggestedReuseIdentifier]
                                                         forIndexPath:indexPath];
    }
    cell.dependencyManager = self.dependencyManager;
    cell.sequence = sequence;
    
    [self.dependencyManager addLoadingBackgroundToBackgroundHost:cell];
    
    return cell;
}

- (CGSize)sizeWithCollectionViewBounds:(CGRect)bounds ofCellForStreamItem:(VStreamItem *)streamItem
{
    if ( [self.noContentCollectionViewCellFactory shouldDisplayNoContentCellForContentClass:[streamItem class]] )
    {
        return [self.noContentCollectionViewCellFactory cellSizeForCollectionViewBounds:bounds];
    }
    
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

@end
