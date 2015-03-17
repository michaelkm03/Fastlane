//
//  VColorPickerDataSource.m
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VColorPickerDataSource.h"
#import "VDependencyManager.h"
#import "VColorOptionCell.h"

@interface VColorPickerDataSource ()

@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VColorPickerDataSource

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager colors:(NSArray *)colors
{
    self = [super init];
    if (self)
    {
        _colors = colors;
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    NSString *identifier = [VColorOptionCell suggestedReuseIdentifier];
    NSBundle *bundle = [NSBundle bundleForClass:[VColorOptionCell class]];
    [collectionView registerNib:[UINib nibWithNibName:identifier bundle:bundle] forCellWithReuseIdentifier:identifier];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.colors.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [VColorOptionCell suggestedReuseIdentifier];
    VColorOptionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.font = [self.dependencyManager fontForKey:@"font.button"];
    
    NSDictionary *colorObject = self.colors[ indexPath.row ];
    UIColor *color = colorObject[ @"color" ];
    NSString *title = colorObject[ @"title" ];
    [cell setColor:color withTitle:title];
    
    return cell;
}

- (id)toolAtIndex:(NSInteger)index
{
    NSDictionary *colorObject = self.colors[ index ];
    return colorObject[ @"color" ];
}

@end