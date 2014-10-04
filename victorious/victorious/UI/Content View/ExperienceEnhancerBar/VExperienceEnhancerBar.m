//
//  VExperienceEnhancerBar.m
//  victorious
//
//  Created by Michael Sena on 10/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VExperienceEnhancerBar.h"

#import "VExperienceEnhancerCell.h"

const CGFloat VExperienceEnhancerDesiredMinimumHeight = 60.0f;

@implementation VExperienceEnhancer

@end

@interface VExperienceEnhancerBar () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *textEntryButton;

@end

@implementation VExperienceEnhancerBar

#pragma mark - Factory Methods

+ (instancetype)experienceEnhancerBar
{
    UINib *nibForView = [UINib nibWithNibName:NSStringFromClass([self class])
                                                     bundle:nil];
    NSArray *nibContents = [nibForView instantiateWithOwner:nil
                                                    options:nil];

    return [nibContents firstObject];
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self.collectionView registerNib:[VExperienceEnhancerCell nibForCell]
          forCellWithReuseIdentifier:[VExperienceEnhancerCell suggestedReuseIdentifier]];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 15.0f;
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
}

#pragma mark - IBActions

- (IBAction)pressedTextEntryButton:(id)sender
{
    if (self.pressedTextEntryHandler)
    {
        self.pressedTextEntryHandler();
    }
}

#pragma mark - Property Accessors

- (void)setActionItems:(NSArray *)actionItems
{
    _actionItems = actionItems;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.actionItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VExperienceEnhancerCell *experienceEnhancerCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VExperienceEnhancerCell suggestedReuseIdentifier]
                                                                                                forIndexPath:indexPath];
    VExperienceEnhancer *enhancerForIndexPath = [self.actionItems objectAtIndex:indexPath.row];
    experienceEnhancerCell.experienceEnhancerTitle = enhancerForIndexPath.labelText;
    experienceEnhancerCell.experienceEnhancerIcon = enhancerForIndexPath.icon;
    return experienceEnhancerCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VExperienceEnhancer *enhancerForIndexPath = [self.actionItems objectAtIndex:indexPath.row];
    if (enhancerForIndexPath.selectionBlock)
    {
        enhancerForIndexPath.selectionBlock();
    }
}

@end
