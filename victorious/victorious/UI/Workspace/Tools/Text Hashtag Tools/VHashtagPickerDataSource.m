//
//  VHashtagPickerDataSource.m
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHashtagPickerDataSource.h"
#import "VHashtagOptionCell.h"
#import "VWorkspaceTool.h"
#import "VDependencyManager.h"

@interface VHashtagPickerDataSource ()

@property (nonatomic, strong) NSArray *hashtags;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VHashtagPickerDataSource

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager hashtags:(NSArray *)hashtags
{
    self = [super init];
    if (self)
    {
        _hashtags = hashtags;
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    NSString *identifier = [VHashtagOptionCell suggestedReuseIdentifier];
    NSBundle *bundle = [NSBundle bundleForClass:[VHashtagOptionCell class]];
    [collectionView registerNib:[UINib nibWithNibName:identifier bundle:bundle] forCellWithReuseIdentifier:identifier];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.hashtags.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [VHashtagOptionCell suggestedReuseIdentifier];
    VHashtagOptionCell *hashtagCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    hashtagCell.font = [self.dependencyManager fontForKey:@"font.button"];
    hashtagCell.selectedColor = [self.dependencyManager colorForKey:@"color.link"];
    hashtagCell.title = self.hashtags[ indexPath.row ];
    return hashtagCell;
}

- (id)toolAtIndex:(NSInteger)index
{
    return self.hashtags[ index ];
}

@end
