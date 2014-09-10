//
//  VNewContentViewController.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNewContentViewController.h"

// Cells
#import "VContentCell.h"
#import "VRealTimeCommentsCell.h"
#import "VAllCommentCell.h"

// Accessory Views
#import "VSectionHandleReusableView.h"

typedef NS_ENUM(NSInteger, VContentViewSection)
{
    VContentViewSectionContent,
    VContentViewSectionRealTimeComments,
    VContentViewSectionAllComments,
    VContentViewSectionCount
};

@interface VNewContentViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *contentCollectionView;

@end

@implementation VNewContentViewController

#pragma mark - UIViewController

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.contentCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    // Register nibs
    [self.contentCollectionView registerNib:[VContentCell nibForCell]
                 forCellWithReuseIdentifier:[VContentCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VRealTimeCommentsCell  nibForCell]
                 forCellWithReuseIdentifier:[VRealTimeCommentsCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VAllCommentCell nibForCell]
                 forCellWithReuseIdentifier:[VAllCommentCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VSectionHandleReusableView nibForCell]
                 forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                        withReuseIdentifier:[VSectionHandleReusableView suggestedReuseIdentifier]];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    VContentViewSection vSection = section;
    switch (vSection)
    {
        case VContentViewSectionRealTimeComments:
            return 1;
        case VContentViewSectionAllComments:
            return 50;
        case VContentViewSectionContent:
            return 1;
        case VContentViewSectionCount:
            return 0;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return VContentViewSectionCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VContentViewSection vSection = indexPath.section;
    switch (vSection)
    {
        case VContentViewSectionContent:
            return [collectionView dequeueReusableCellWithReuseIdentifier:[VContentCell suggestedReuseIdentifier]
                                                             forIndexPath:indexPath];
        case VContentViewSectionRealTimeComments:
            return [collectionView dequeueReusableCellWithReuseIdentifier:[VRealTimeCommentsCell suggestedReuseIdentifier]
                                                             forIndexPath:indexPath];
        case VContentViewSectionAllComments:
            return [collectionView dequeueReusableCellWithReuseIdentifier:[VAllCommentCell suggestedReuseIdentifier]
                                                             forIndexPath:indexPath];
        case VContentViewSectionCount:
            return nil;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    VContentViewSection vSection = indexPath.section;
    switch (vSection)
    {
        case VContentViewSectionContent:
            return nil;
        case VContentViewSectionRealTimeComments:
            return nil;
        case VContentViewSectionAllComments:
            return [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                      withReuseIdentifier:[VSectionHandleReusableView suggestedReuseIdentifier]
                                                             forIndexPath:indexPath];
        case VContentViewSectionCount:
            return nil;
    }
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VContentViewSection vSection = indexPath.section;
    switch (vSection)
    {
        case VContentViewSectionContent:
            return CGSizeMake(320, 320);
        case VContentViewSectionRealTimeComments:
            return CGSizeMake(320, 110);
        case VContentViewSectionAllComments:
            return CGSizeMake(320, 60);
        case VContentViewSectionCount:
            return CGSizeZero;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section
{
    VContentViewSection vSection = section;
    switch (vSection) {
        case VContentViewSectionContent:
            return CGSizeZero;
        case VContentViewSectionRealTimeComments:
            return CGSizeZero;
        case VContentViewSectionAllComments:
            return CGSizeMake(320, 20);
        case VContentViewSectionCount:
            return CGSizeZero;
    }
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:0]] == NSOrderedSame)
    {
        [self.contentCollectionView setContentOffset:CGPointMake(0, 0)
                                            animated:YES];
    }
}

#pragma mark UIScrollView

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (targetContentOffset->y < (110.0f))
    {
        *targetContentOffset = CGPointMake(0, 0);
    }
}

@end
