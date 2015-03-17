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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForSequence:(VSequence *)sequence atIndexPath:(NSIndexPath *)indexPath
{
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
        return cell;
    }
    else
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VInsetStreamCollectionCell suggestedReuseIdentifier]
                                                         forIndexPath:indexPath];
    }
    cell.dependencyManager = self.dependencyManager;
    cell.sequence = sequence;
    return cell;
}

- (CGSize)sizeWithCollectionViewBounds:(CGRect)bounds ofCellForSequence:(VSequence *)sequence
{
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
