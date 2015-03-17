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
#import "VHashtagType.h"

@interface VHashtagPickerDataSource ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VHashtagPickerDataSource

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
    NSString *identifier = [VHashtagOptionCell suggestedReuseIdentifier];
    NSBundle *bundle = [NSBundle bundleForClass:[VHashtagOptionCell class]];
    [collectionView registerNib:[UINib nibWithNibName:identifier bundle:bundle] forCellWithReuseIdentifier:identifier];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tools.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [VHashtagOptionCell suggestedReuseIdentifier];
    VHashtagType *hashtagType = self.tools[ indexPath.row ];
    VHashtagOptionCell *hashtagCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    hashtagCell.font = [self.dependencyManager fontForKey:@"font.button"];
    hashtagCell.selectedColor = [self.dependencyManager colorForKey:@"color.link"];
    hashtagCell.title = hashtagType.hashtagText;
    return hashtagCell;
}

@end
