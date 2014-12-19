//
//  VTickerPickerViewController.h
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTickerPickerViewController.h"
#import "VBasicToolPickerCell.h"
#import "VDependencyManager.h"

@interface VTickerPickerViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) UIView *selectionIndicatorView;
@property (nonatomic, copy) NSArray *tools;
@property (nonatomic, strong) UIColor *accentColor;

@end

@implementation VTickerPickerViewController

@synthesize onToolSelection = _onToolSelection;

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *workspaceStoryboard = [UIStoryboard storyboardWithName:@"Workspace"
                                                                  bundle:nil];
    VTickerPickerViewController *toolPicker = [workspaceStoryboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    toolPicker.dependencyManager = dependencyManager;
    toolPicker.clearsSelectionOnViewWillAppear = NO;
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
    [self notifyNewSelection];
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

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return (NSInteger)self.tools.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VBasicToolPickerCell *pickerCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VBasicToolPickerCell suggestedReuseIdentifier]
                                                                                 forIndexPath:indexPath];
    id <VWorkspaceTool> toolForIndexPath = self.tools[indexPath.row];
    
    if (self.configureItemLabel)
    {
        self.configureItemLabel(pickerCell.label, toolForIndexPath);
    }
    else
    {
        pickerCell.label.text = toolForIndexPath.title;
        pickerCell.label.font = [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    }
    
    
    return pickerCell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [VBasicToolPickerCell desiredSizeWithCollectionViewBounds:self.collectionView.bounds];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView scrollToItemAtIndexPath:indexPath
                           atScrollPosition:UICollectionViewScrollPositionTop
                                   animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.selectionIndicatorView.frame = [self selectionFrame];
    
    NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
    NSIndexPath *indexPathForPoint = [self.collectionView indexPathForItemAtPoint:CGPointMake(CGRectGetMidX(self.collectionView.bounds),
                                                                                              self.collectionView.contentOffset.y + ([VBasicToolPickerCell desiredSizeWithCollectionViewBounds:self.collectionView.bounds].height / 2))];
    if ([indexPathForPoint compare:selectedIndexPath] == NSOrderedSame)
    {
        return;
    }
    
    [self.collectionView selectItemAtIndexPath:indexPathForPoint
                                      animated:YES
                                scrollPosition:UICollectionViewScrollPositionNone];
    [self notifyNewSelection];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    // Always land on a cell
    NSIndexPath *indexPathForTargetOffset = [self.collectionView indexPathForItemAtPoint:CGPointMake(targetContentOffset->x + CGRectGetMidX([self selectionFrame]) - CGRectGetMinX([self selectionFrame]),
                                                                                                     targetContentOffset->y + CGRectGetMidY([self selectionFrame]) - CGRectGetMinY([self selectionFrame]))];
    *targetContentOffset = [self.collectionView layoutAttributesForItemAtIndexPath:indexPathForTargetOffset].frame.origin;
}

#pragma mark - VToolPicker

- (void)setOnToolSelection:(void (^)(id<VWorkspaceTool>))onToolSelection
{
    _onToolSelection = [onToolSelection copy];
}

- (void)setTools:(NSArray *)tools
{
    _tools = [tools copy];
}

- (id <VWorkspaceTool>)selectedTool
{
    NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
    if (selectedIndexPath == nil)
    {
        return nil;
    }
    
    return self.tools[selectedIndexPath.row];
}

#pragma mark - Internal Methods

- (void)notifyNewSelection
{
    if (self.onToolSelection)
    {
        self.onToolSelection([self selectedTool]);
    }
}

- (CGRect)selectionFrame
{
    return CGRectMake(self.collectionView.contentOffset.x,
                      self.collectionView.contentOffset.y,
                      CGRectGetWidth(self.collectionView.bounds),
                      [VBasicToolPickerCell desiredSizeWithCollectionViewBounds:self.collectionView.bounds].height);
}

@end
