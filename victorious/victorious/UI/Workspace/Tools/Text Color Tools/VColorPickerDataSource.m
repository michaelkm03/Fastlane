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
#import "VColorType.h"

@interface VColorPickerDataSource ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VColorPickerDataSource

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
    NSString *identifier = [VColorOptionCell suggestedReuseIdentifier];
    NSBundle *bundle = [NSBundle bundleForClass:[VColorOptionCell class]];
    [collectionView registerNib:[UINib nibWithNibName:identifier bundle:bundle] forCellWithReuseIdentifier:identifier];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tools.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [VColorOptionCell suggestedReuseIdentifier];
    VColorOptionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    VColorType *colorType = self.tools[ indexPath.row ];
    cell.font = [self.dependencyManager fontForKey:@"font.button2"];
    [cell setColor:colorType.color withTitle:colorType.title];
    
    return cell;
}

@end