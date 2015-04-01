//
//  VTickerPickerViewController.h
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTickerPickerViewController.h"
#import "VDependencyManager.h"
#import "VBasicToolPickerCell.h"

@interface VTickerPickerViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) UIView *selectionIndicatorView;
@property (nonatomic, strong) UIColor *accentColor;
@property (nonatomic, strong) NSIndexPath *blockScrollingSelectionUntilReached;
@property (nonatomic, strong) NSIndexPath *selectedToolIndexPath;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) IBOutlet VTickerPickerSelection *tickerPickerSelection;

@end

@implementation VTickerPickerViewController

@synthesize delegate;
@synthesize dataSource;
@synthesize selectedTool;

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *workspaceStoryboard = [UIStoryboard storyboardWithName:@"Workspace" bundle:nil];
    VTickerPickerViewController *toolPicker = [workspaceStoryboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    toolPicker.dependencyManager = dependencyManager;
    toolPicker.accentColor = [dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    VTickerPickerSelectionMode selectionMode = [VTickerPickerSelection selectionModeFromString:[dependencyManager stringForKey:VTickerPickerSelectionModeKey]];
    toolPicker.selectionMode = selectionMode < 0 ? VTickerPickerSelectionModeSingle : selectionMode;
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
    
    self.collectionView.allowsMultipleSelection = self.selectionMode != VTickerPickerSelectionModeSingle;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    NSAssert( self.dataSource != nil, @"A VTickerPickerViewController must have a VToolPickerDataSource property set." );
    
    self.collectionView.dataSource = self.dataSource;
    [self.dataSource registerCellsWithCollectionView:self.collectionView];
    [self.collectionView reloadData];
    
    if ( self.selectionMode == VTickerPickerSelectionModeSingle )
    {
        [self addSelectionIndicatorView];
    }
    
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

#pragma mark - VToolPicker Public selection methods

- (BOOL)toolIsSelectedAtIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    return [self.tickerPickerSelection isIndexPathSelected:indexPath];
}

- (void)selectToolAtIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self itemSelectedAtIndexPath:indexPath];
}

- (void)deselectToolAtIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self itemDeselectedAtIndexPath:indexPath];
}

#pragma mark - Selection management

- (void)addSelectionIndicatorView
{
    self.selectionIndicatorView = [[UIView alloc] initWithFrame:[self selectionFrame]];
    self.selectionIndicatorView.backgroundColor = [self.accentColor colorWithAlphaComponent:0.5f];
    self.selectionIndicatorView.userInteractionEnabled = NO;
    [self.collectionView addSubview:self.selectionIndicatorView];
    [self.collectionView sendSubviewToBack:self.selectionIndicatorView];
}

- (void)itemSelectedAtIndexPath:(NSIndexPath *)indexPath
{
    if ( self.selectionMode == VTickerPickerSelectionModeSingle )
    {
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        self.blockScrollingSelectionUntilReached = indexPath;
        self.selectedToolIndexPath = indexPath;
    }
    else if ( self.selectionMode == VTickerPickerSelectionModeMultiple )
    {
        [self.tickerPickerSelection indexPathWasSelected:indexPath];
        [self.collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
    }
    [self.delegate toolPicker:self didSelectItemAtIndex:indexPath.row];
}

- (void)itemDeselectedAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [self.delegate respondsToSelector:@selector(toolPicker:didDeselectItemAtIndex:)] )
    {
        [self.delegate toolPicker:self didDeselectItemAtIndex:indexPath.row];
    }
    
    if ( self.selectionMode == VTickerPickerSelectionModeMultiple )
    {
        [self.tickerPickerSelection indexPathWasDeselected:indexPath];
        [self.collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
    }
}

- (void)selectRowOnScroll
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
    self.selectedToolIndexPath = indexPathForPoint;
    [self.delegate toolPicker:self didSelectItemAtIndex:indexPathForPoint.row];
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

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self itemSelectedAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self itemDeselectedAtIndexPath:indexPath];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ( self.selectionMode == VTickerPickerSelectionModeSingle )
    {
        [self selectRowOnScroll];
    }
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
