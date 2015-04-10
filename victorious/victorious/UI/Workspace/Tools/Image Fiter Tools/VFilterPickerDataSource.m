//
//  VFilterPickerDataSource.m
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFilterPickerDataSource.h"
#import "VBasicToolPickerCell.h"
#import "VWorkspaceTool.h"
#import "VFilterTypeTool.h"
#import "VDependencyManager.h"

@interface VFilterPickerDataSource ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VFilterPickerDataSource

@synthesize tools;

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    NSString *identifier = [VBasicToolPickerCell suggestedReuseIdentifier];
    NSBundle *bundle = [NSBundle bundleForClass:[VBasicToolPickerCell class]];
    [collectionView registerNib:[UINib nibWithNibName:identifier bundle:bundle] forCellWithReuseIdentifier:identifier];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tools.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [VBasicToolPickerCell suggestedReuseIdentifier];
    VBasicToolPickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    VFilterTypeTool *filterType = (VFilterTypeTool *)self.tools[ indexPath.row ];
    cell.label.text = filterType.title;
    cell.label.font = [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    return cell;
}

@end
