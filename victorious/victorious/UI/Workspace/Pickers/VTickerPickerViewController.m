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

@end

@implementation VTickerPickerViewController

@synthesize pickerDelegate; //< VToolPicker
@synthesize dataSource; //< VCollectionToolPicker

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *workspaceStoryboard = [UIStoryboard storyboardWithName:@"Workspace" bundle:nil];
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

#pragma mark - UIViewController Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.allowsMultipleSelection = YES;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    NSAssert( self.dataSource != nil, @"A VTickerPickerViewController must have a VCollectionToolPickerDataSource property set." );
    
    self.collectionView.dataSource = self.dataSource;
    [self.dataSource registerCellsWithCollectionView:self.collectionView];
    [self.collectionView reloadData];
    
    [self addSelectionIndicatorView];
    
    NSIndexPath *defaultIndexPathSelection = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.collectionView selectItemAtIndexPath:defaultIndexPathSelection
                                      animated:NO
                                scrollPosition:UICollectionViewScrollPositionNone];
    self.selectedToolIndexPath = defaultIndexPathSelection;
    [self.pickerDelegate toolPicker:self didSelectTool:self.selectedTool];
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

#pragma mark - VPickerDelegate

- (id<VWorkspaceTool>)selectedTool
{
    return [self.dataSource tools][self.selectedToolIndexPath.row];
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
    [self.pickerDelegate toolPicker:self didSelectTool:self.selectedTool];
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
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    self.blockScrollingSelectionUntilReached = indexPath;
    self.selectedToolIndexPath = indexPath;
    
    [self.pickerDelegate toolPicker:self didSelectTool:self.selectedTool];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self selectRowOnScroll];
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

#pragma mark - VCollectionToolPicker

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
