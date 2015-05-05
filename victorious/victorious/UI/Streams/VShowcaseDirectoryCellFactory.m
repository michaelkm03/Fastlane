//
//  VShowcaseDirectoryCellFactory.m
//  victorious
//
//  Created by Sharif Ahmed on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VShowcaseDirectoryCellFactory.h"
#import "VShowcaseDirectoryCell.h"
#import "VDependencyManager.h"
#import "VStreamItem+Fetcher.h"
#import "VStream.h"
#import "VDirectoryCollectionFlowLayout.h"

static CGFloat const kDirectoryInset = 5.0f;

@interface VShowcaseDirectoryCellFactory ()

@property (nonatomic, strong) NSObject <VDirectoryCellFactory> *groupedDirectoryCellFactory;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VShowcaseDirectoryCellFactory

@synthesize delegate;

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (VDirectoryCollectionFlowLayout *)collectionViewFlowLayout
{
    return [[VDirectoryCollectionFlowLayout alloc] init];
}

- (CGSize)sizeWithCollectionViewBounds:(CGRect)bounds ofCellForStreamItem:(VStreamItem *)streamItem
{
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat cellHeight = [VShowcaseDirectoryCell desiredSizeWithCollectionViewBounds:bounds].height;
    return CGSizeMake( width, cellHeight );
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[VShowcaseDirectoryCell nibForCell] forCellWithReuseIdentifier:[VShowcaseDirectoryCell suggestedReuseIdentifier]];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForStreamItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [VShowcaseDirectoryCell suggestedReuseIdentifier];
    VShowcaseDirectoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.stream = (VStream *)streamItem;
    cell.dependencyManager = self.dependencyManager;
    return cell;
}

- (CGFloat)minimumInterItemSpacing
{
    return 0.0f;
}

- (CGFloat)minimumLineSpacing
{
    return 1.0f;
}

- (UIEdgeInsets)sectionInsets
{
    return UIEdgeInsetsMake(self.groupedDirectoryCellFactory.sectionInsets.top, 0.0f, kDirectoryInset, 0.0f);
}

@end
