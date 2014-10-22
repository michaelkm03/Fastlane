//
//  VExperienceEnhancerBar.m
//  victorious
//
//  Created by Michael Sena on 10/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VExperienceEnhancerBar.h"

#import "VExperienceEnhancer.h"
#import "VExperienceEnhancerCell.h"

const CGFloat VExperienceEnhancerDesiredMinimumHeight = 60.0f;
static const CGFloat kExperienceEnhancerSelectionScale = 1.5f;
static const CGFloat kExperienceEnhancerSelectionAnimationGrowDuration = 0.15f;
static const CGFloat kExperienceEnhancerSelectionAnimationDecayDuration = 0.1f;

@interface VExperienceEnhancerBar () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *enhancers;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

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
    self.collectionView.allowsSelection = YES;
    self.collectionView.allowsMultipleSelection = NO;
    
    [self.collectionView registerNib:[VExperienceEnhancerCell nibForCell]
          forCellWithReuseIdentifier:[VExperienceEnhancerCell suggestedReuseIdentifier]];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 15.0f;
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    
    [self reloadData];
}

#pragma mark - Property Accessors

- (void)setDataSource:(id<VExperienceEnhancerBarDataSource>)dataSource
{
    _dataSource = dataSource;
    
    [self reloadData];
}

#pragma mark - Public Methods
    
- (void)reloadData
{
    NSMutableArray *enhancers = [[NSMutableArray alloc] init];
    
    NSInteger enhancerCount = [self.dataSource numberOfExperienceEnhancers];
    
    for (NSInteger enhancerIndex = 0; enhancerIndex < enhancerCount; enhancerIndex++)
    {
        VExperienceEnhancer *enhancerForIndex = [self.dataSource experienceEnhancerForIndex:enhancerIndex];
        [enhancers addObject:enhancerForIndex];
    }
    
    self.enhancers = [NSArray arrayWithArray:enhancers];
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.enhancers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VExperienceEnhancerCell *experienceEnhancerCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VExperienceEnhancerCell suggestedReuseIdentifier]
                                                                                                forIndexPath:indexPath];
    VExperienceEnhancer *enhancerForIndexPath = [self.enhancers objectAtIndex:indexPath.row];
    experienceEnhancerCell.experienceEnhancerTitle = enhancerForIndexPath.labelText;
    experienceEnhancerCell.experienceEnhancerIcon = enhancerForIndexPath.iconImage;
    return experienceEnhancerCell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [VExperienceEnhancerCell desiredSizeWithCollectionViewBounds:self.collectionView.bounds];
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VExperienceEnhancer *enhancerForIndexPath = [self.enhancers objectAtIndex:indexPath.row];
    if (self.selectionBlock)
    {
        UICollectionViewCell *selectedCell = [self.collectionView cellForItemAtIndexPath:indexPath];
        CGPoint convertedCenter = [selectedCell.superview convertPoint:selectedCell.center
                                                                toView:self];
        self.selectionBlock(enhancerForIndexPath, convertedCenter);
        
        [self.delegate didVoteWithExperienceEnhander:enhancerForIndexPath targetPoint:convertedCenter];
    }
    else
    {
        [self.delegate didVoteWithExperienceEnhander:enhancerForIndexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *selectedCell = [self.collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:kExperienceEnhancerSelectionAnimationGrowDuration
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^
     {
         selectedCell.transform = CGAffineTransformMakeScale(kExperienceEnhancerSelectionScale, kExperienceEnhancerSelectionScale);
     }
                     completion:nil];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *selectedCell = [self.collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:kExperienceEnhancerSelectionAnimationDecayDuration
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^
     {
         selectedCell.transform = CGAffineTransformIdentity;
     }
                     completion:nil];

}

@end
