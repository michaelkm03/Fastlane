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
#import "VLargeNumberFormatter.h"
#import "VObjectManager+Login.h"
#import "VPurchaseManager.h"
#import "VVoteType.h"

#import <KVOController/FBKVOController.h>

NSString * const VExperienceEnhancerBarDidRequireLoginNotification = @"VExperienceEnhancerBarDidRequiredLoginNotification";
NSString * const VExperienceEnhancerBarDidRequirePurchasePrompt = @"VExperienceEnhancerBarDidRequirePurchasePrompt";

const CGFloat VExperienceEnhancerDesiredMinimumHeight = 60.0f;

static const CGFloat kExperienceEnhancerSelectionScale = 1.5f;
static const CGFloat kExperienceEnhancerSelectionAnimationGrowDuration = 0.1f;
static const CGFloat kExperienceEnhancerSelectionAnimationDecayDuration = 0.2f;

@interface VExperienceEnhancerBar () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *enhancers;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) VLargeNumberFormatter *numberFormatter;
@property (nonatomic, strong) NSMutableSet *observedExperienceEnhancers;

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
    
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.allowsSelection = YES;
    self.collectionView.allowsMultipleSelection = NO;
    
    self.numberFormatter = [[VLargeNumberFormatter alloc] init];
    
    [self.collectionView registerNib:[VExperienceEnhancerCell nibForCell]
          forCellWithReuseIdentifier:[VExperienceEnhancerCell suggestedReuseIdentifier]];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 15.0f;
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    
    self.enabled = YES;
    [self reloadData];
}

#pragma mark - Property Accessors

- (void)setDataSource:(id<VExperienceEnhancerBarDataSource>)dataSource
{
    _dataSource = dataSource;
    
    [self reloadData];
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(VExperienceEnhancerCell *cell, NSUInteger idx, BOOL *stop)
    {
        cell.enabled = _enabled;
    }];
}

#pragma mark - Public Methods
    
- (void)reloadData
{
    for (id observedEnhancer in self.observedExperienceEnhancers)
    {
        [self.KVOController unobserve:observedEnhancer];
    }
    self.observedExperienceEnhancers = [[NSMutableSet alloc] init];
    
    NSInteger enhancerCount = [self.dataSource numberOfExperienceEnhancers];
    
    NSMutableArray *enhancers = [[NSMutableArray alloc] init];
    
    for (NSInteger enhancerIndex = 0; enhancerIndex < enhancerCount; enhancerIndex++)
    {
        VExperienceEnhancer *enhancerForIndex = [self.dataSource experienceEnhancerForIndex:enhancerIndex];
        [enhancers addObject:enhancerForIndex];
        [self setupKVOControllerWithExperienceEnhancer:enhancerForIndex atIndex:enhancerIndex];
        [self.observedExperienceEnhancers addObject:enhancerForIndex];
    }
    
    self.enhancers = [NSArray arrayWithArray:enhancers];
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.enhancers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VExperienceEnhancerCell *experienceEnhancerCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VExperienceEnhancerCell suggestedReuseIdentifier]
                                                                                                forIndexPath:indexPath];
    VExperienceEnhancer *enhancerForIndexPath = [self.enhancers objectAtIndex:indexPath.row];
    experienceEnhancerCell.experienceEnhancerTitle = [self.numberFormatter stringForInteger:enhancerForIndexPath.voteCount];
    experienceEnhancerCell.experienceEnhancerIcon = enhancerForIndexPath.iconImage;
    experienceEnhancerCell.isLocked = enhancerForIndexPath.isLocked;
    experienceEnhancerCell.enabled = self.enabled;
    experienceEnhancerCell.dependencyManager = self.dependencyManager;
    return experienceEnhancerCell;
}

#pragma mark - KVOConroller

- (void)setupKVOControllerWithExperienceEnhancer:(VExperienceEnhancer *)enhancer atIndex:(NSUInteger)index
{
    typeof(self) __weak welf = self;
    [self.KVOController observe:enhancer
                        keyPath:NSStringFromSelector(@selector(voteCount))
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         VExperienceEnhancerCell *experienceEnhancerCell = (VExperienceEnhancerCell *)[welf.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
         if ( experienceEnhancerCell != nil )
         {
             experienceEnhancerCell.experienceEnhancerTitle = [welf.numberFormatter stringForInteger:enhancer.voteCount];
         }
     }];
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [VExperienceEnhancerCell desiredSizeWithCollectionViewBounds:self.collectionView.bounds];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VExperienceEnhancerCell *experienceEnhancerCell = (VExperienceEnhancerCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ( !experienceEnhancerCell.enabled )
    {
        return;
    }
    
    VExperienceEnhancer *enhancerForIndexPath = [self.enhancers objectAtIndex:indexPath.row];
    
    // Check if the user must buy this experience enhancer first
    if ( enhancerForIndexPath.isLocked  )
    {
        NSDictionary *userInfo = @{ @"experienceEnhancer" : enhancerForIndexPath };
        [[NSNotificationCenter defaultCenter] postNotificationName:VExperienceEnhancerBarDidRequirePurchasePrompt object:nil userInfo:userInfo];
        return;
    }
    
    // Check if the user is logged in first
    if ( ![VObjectManager sharedManager].authorized )
    {
        NSDictionary *userInfo = @{ @"experienceEnhancerIndexPath" : indexPath };
        [[NSNotificationCenter defaultCenter] postNotificationName:VExperienceEnhancerBarDidRequireLoginNotification object:nil userInfo:userInfo];
        return;
    }
    
    [self selectExperienceEnhancerAtIndex:indexPath];
}

- (void)selectExperienceEnhancerAtIndex:(NSIndexPath *)indexPath
{
    VExperienceEnhancer *enhancerForIndexPath = [self.enhancers objectAtIndex:indexPath.row];
    
    // Incrememnt the vote count
    [enhancerForIndexPath vote];
    
    // Call the selection block (configured in VNewContentViewController) to play the animations
    if (self.selectionBlock)
    {
        UICollectionViewCell *selectedCell = [self.collectionView cellForItemAtIndexPath:indexPath];
        CGPoint convertedCenter = [selectedCell.superview convertPoint:selectedCell.center toView:self];
        self.selectionBlock(enhancerForIndexPath, convertedCenter);
    }
    
    if ( [self.delegate respondsToSelector:@selector(experienceEnhancerSelected:)] )
    {
        [self.delegate experienceEnhancerSelected:enhancerForIndexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ( !self.enabled )
    {
        return;
    }
    
    VExperienceEnhancer *enhancerForIndexPath = [self.enhancers objectAtIndex:indexPath.row];
    if ( enhancerForIndexPath.isLocked  )
    {
        return;
    }
    
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
    if ( !self.enabled )
    {
        return;
    }
    
    VExperienceEnhancer *enhancerForIndexPath = [self.enhancers objectAtIndex:indexPath.row];
    if ( enhancerForIndexPath.isLocked  )
    {
        return;
    }
    
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

#pragma mark - Appearance styling

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    for ( VExperienceEnhancerCell *cell in self.collectionView.visibleCells )
    {
        cell.dependencyManager = dependencyManager;
    }
}

@end
