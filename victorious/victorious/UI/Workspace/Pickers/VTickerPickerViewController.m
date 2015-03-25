//
//  VTickerPickerViewController.h
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTickerPickerViewController.h"
#import "VDependencyManager.h"

#warning Remove all uses of this cell here for something generic 
#import "VBasicToolPickerCell.h"

@interface VTickerPickerViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) UIView *selectionIndicatorView;
@property (nonatomic, strong) UIColor *accentColor;
@property (nonatomic, strong) NSIndexPath *blockScrollingSelectionUntilReached;

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@end

@implementation VTickerPickerViewController

@synthesize delegate;
@synthesize dataSource;

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *workspaceStoryboard = [UIStoryboard storyboardWithName:@"Workspace"
                                                                  bundle:nil];
    VTickerPickerViewController *toolPicker = [workspaceStoryboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    toolPicker.dependencyManager = dependencyManager;
    toolPicker.accentColor = [dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    return toolPicker;
}

#pragma mark - NSObject

- (void)dealloc
{
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

#pragma mark - UIViewController
#pragma mark Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.allowsMultipleSelection = NO;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    NSAssert( self.dataSource != nil, @"A VTickerPickerViewController must have a VToolPickerDataSource property set." );
    
    self.collectionView.dataSource = self.dataSource;
    [self.dataSource registerCellsWithCollectionView:_collectionView];
    [self.collectionView reloadData];
    
    self.selectionIndicatorView =
    ({
        UIView *selectionView = [[UIView alloc] initWithFrame:[self selectionFrame]];
        selectionView.backgroundColor = [self.accentColor colorWithAlphaComponent:0.5f];
        [self.collectionView addSubview:selectionView];
        [self.collectionView sendSubviewToBack:selectionView];
        selectionView;
    });
    
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                      animated:NO
                                scrollPosition:UICollectionViewScrollPositionNone];
    
    [self.delegate toolPicker:self didSelectItemAtIndex:0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.collectionView flashScrollIndicators];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.collectionView sendSubviewToBack:self.selectionIndicatorView];
    
    // Inset enough at the bottom to show only one row at the top when fully scrolled
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat singleCellHeight = [VBasicToolPickerCell desiredSizeWithCollectionViewBounds:self.collectionView.bounds].height;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.collectionView.bounds) - singleCellHeight, 0);
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [VBasicToolPickerCell desiredSizeWithCollectionViewBounds:self.collectionView.bounds];
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [[self.collectionView indexPathsForSelectedItems] enumerateObjectsUsingBlock:^(NSIndexPath *selectedIndexPath, NSUInteger idx, BOOL *stop)
     {
         if ([selectedIndexPath compare:indexPath] == NSOrderedSame)
         {
             [collectionView flashScrollIndicators];
         }
     }];
    
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView scrollToItemAtIndexPath:indexPath
                           atScrollPosition:UICollectionViewScrollPositionTop
                                   animated:YES];
    self.blockScrollingSelectionUntilReached = indexPath;
    [self.delegate toolPicker:self didSelectItemAtIndex:indexPath.row];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.selectionIndicatorView.frame = [self selectionFrame];
    
    NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
    NSIndexPath *indexPathForPoint = [self.collectionView indexPathForItemAtPoint:CGPointMake(CGRectGetMidX(self.collectionView.bounds),
                                                                                              self.collectionView.contentOffset.y + ([VBasicToolPickerCell desiredSizeWithCollectionViewBounds:self.collectionView.bounds].height / 2))];
    
    if ([self.blockScrollingSelectionUntilReached compare:indexPathForPoint] != NSOrderedSame)
    {
        return;
    }
    else
    {
        self.blockScrollingSelectionUntilReached = nil;
    }
    
    if ([indexPathForPoint compare:selectedIndexPath] == NSOrderedSame)
    {
        return;
    }
    
    [self.collectionView selectItemAtIndexPath:indexPathForPoint
                                      animated:YES
                                scrollPosition:UICollectionViewScrollPositionNone];
    [self.delegate toolPicker:self didSelectItemAtIndex:indexPathForPoint.row];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.blockScrollingSelectionUntilReached = nil;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    // Always land on a cell
    NSIndexPath *indexPathForTargetOffset = [self.collectionView indexPathForItemAtPoint:CGPointMake(targetContentOffset->x + CGRectGetMidX([self selectionFrame]) - CGRectGetMinX([self selectionFrame]),
                                                                                                     targetContentOffset->y + CGRectGetMidY([self selectionFrame]) - CGRectGetMinY([self selectionFrame]))];
    if ( indexPathForTargetOffset != nil )
    {
        *targetContentOffset = [self.collectionView layoutAttributesForItemAtIndexPath:indexPathForTargetOffset].frame.origin;
    }
}

#pragma mark - VToolPicker

- (void)reloadData
{
    [self.collectionView reloadData];
}

#pragma mark - Internal Methods

- (CGRect)selectionFrame
{
    return CGRectMake(self.collectionView.contentOffset.x,
                      self.collectionView.contentOffset.y,
                      CGRectGetWidth(self.collectionView.bounds),
                      [VBasicToolPickerCell desiredSizeWithCollectionViewBounds:self.collectionView.bounds].height);
}

@end
