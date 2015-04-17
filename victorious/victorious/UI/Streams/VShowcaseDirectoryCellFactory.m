//
//  VShowcaseDirectoryCellFactory.m
//  victorious
//
//  Created by Sharif Ahmed on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VShowcaseDirectoryCellFactory.h"
#import "VDependencyManager.h"
#import "VShowcaseDirectoryCell.h"
#import "VStreamItem+Fetcher.h"
#import "VStream.h"

static CGFloat const kDirectoryInset = 5.0f;
static NSString * const kGroupedDirectoryCellFactoryKey = @"groupedCell";

@interface VShowcaseDirectoryCellFactory ()

@property (nonatomic, strong) NSObject <VDirectoryCellFactory> *groupedDirectoryCellFactory;

@end

@implementation VShowcaseDirectoryCellFactory

@synthesize dependencyManager;
@synthesize delegate;

- (instancetype)initWithDependencyManager:(VDependencyManager *)localDependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        dependencyManager = localDependencyManager;
        _groupedDirectoryCellFactory = [dependencyManager templateValueConformingToProtocol:@protocol(VDirectoryCellFactory) forKey:kGroupedDirectoryCellFactoryKey];
        NSAssert(_groupedDirectoryCellFactory != nil, @"VShowcaseDirectoryCellFactory requires that a valid directory cell factory be returned from the groupedCell of the dependency manager used to create it");
    }
    return self;
}

- (CGSize)desiredSizeForCollectionViewBounds:(CGRect)bounds andStreamItem:(VStreamItem *)streamItem
{
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat cellHeight = [VShowcaseDirectoryCell desiredSizeWithCollectionViewBounds:bounds].height;
    return CGSizeMake( width, cellHeight );
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[VShowcaseDirectoryCell nibForCell] forCellWithReuseIdentifier:[VShowcaseDirectoryCell suggestedReuseIdentifier]];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForIndexPath:(NSIndexPath *)indexPath withStreamItem:(VStreamItem *)streamItem
{
    NSString *identifier = [VShowcaseDirectoryCell suggestedReuseIdentifier];
    VShowcaseDirectoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.stream = (VStream *)streamItem;
    cell.dependencyManager = self.dependencyManager;
    cell.directoryCellFactory = self.groupedDirectoryCellFactory;
    cell.delegate = self.delegate;
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

- (UIEdgeInsets)sectionEdgeInsets
{
    return UIEdgeInsetsMake(self.groupedDirectoryCellFactory.sectionEdgeInsets.top, 0.0f, kDirectoryInset, 0.0f);
}

@end
