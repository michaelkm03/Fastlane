//
//  VUtilityButtonsViewController.m
//  victorious
//
//  Created by Patrick Lynch on 12/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUtilityButtonsViewController.h"
#import "VUtilityButtonCell.h"
#import "UIView+AutoLayout.h"

static const CGFloat kCollectionViewSectionsCount = 1;

@interface VUtilityButtonsViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, assign) CGRect startingFrame;

@end

@implementation VUtilityButtonsViewController

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self)
    {
        _startingFrame = frame;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewLayout.sectionInset = UIEdgeInsetsZero;
    collectionViewLayout.minimumInteritemSpacing = 0.0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.startingFrame collectionViewLayout:collectionViewLayout];
    self.collectionView.scrollEnabled = NO;
    self.collectionView.delaysContentTouches = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    
    [self.view v_addFitToParentConstraintsToSubview:self.collectionView];
    
    NSString *reuseIdentifier = [VUtilityButtonCell reuseIdentifier];
    UINib *nib = [UINib nibWithNibName:reuseIdentifier bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)dealloc
{
    // Since this view will be added to another view that persists beyond the lifetime
    // of the view controller (self), we have to kill the collection view so it doesn't try to send
    // its datasource and delegate methods to a deallocated instance (self).
    [self.collectionView removeFromSuperview];
    self.collectionView = nil;
}

- (void)constraintsDidUpdate
{
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VUtilityButtonCell *buttonCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VUtilityButtonCell reuseIdentifier] forIndexPath:indexPath];
    buttonCell.iconImageView.image = [self.delegate.cellDelegate iconImageForButtonAtIndex:indexPath.row];
    buttonCell.backgroundColor = [self.delegate.cellDelegate backgroundColorForButtonAtIndex:indexPath.row];
    buttonCell.intendedFullWidth = [self.delegate.cellDelegate utilityButtonWidth];
    return buttonCell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return kCollectionViewSectionsCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.delegate.cellDelegate numberOfUtilityButtons];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = CGRectGetHeight( collectionView.frame );
    NSUInteger buttonCount = [self.delegate.cellDelegate numberOfUtilityButtons];
    if ( buttonCount == 0 )
    {
        // This prevents possibly dividing by zero below and returning NaN
        return CGSizeMake( 0, height );
    }
    CGFloat totalWidth = CGRectGetWidth( collectionView.frame);
    CGFloat width = totalWidth / (CGFloat)buttonCount;
    return CGSizeMake( width, height );
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VUtilityButtonCell *buttonCell = (VUtilityButtonCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self.delegate.cellDelegate utilityButton:buttonCell selectedAtIndex:indexPath.row];
    [self.delegate utilityButtonSelected];
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    VUtilityButtonCell *buttonCell = (VUtilityButtonCell *)[collectionView cellForItemAtIndexPath:indexPath];
    buttonCell.highlighted = YES;
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    VUtilityButtonCell *buttonCell = (VUtilityButtonCell *)[collectionView cellForItemAtIndexPath:indexPath];
    buttonCell.highlighted = NO;
}

@end
