//
//  VMultiplePickerViewController.h
//  victorious
//
//  Created by Patrick Lynch on 4/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VMultiplePickerViewController.h"
#import "VDependencyManager.h"
#import "VBasicToolPickerCell.h"
#import "VMultiplePickerSelection.h"

@interface VMultiplePickerViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VMultiplePickerSelection *currentSelection;

@end

@implementation VMultiplePickerViewController

@synthesize multiplePickerDelegate; //< VMultipleToolPicker
@synthesize dataSource; //< VCollectionToolPicker

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *workspaceStoryboard = [UIStoryboard storyboardWithName:@"Workspace" bundle:nil];
    VMultiplePickerViewController *toolPicker = [workspaceStoryboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    toolPicker.dependencyManager = dependencyManager;
    return toolPicker;
}

#pragma mark - NSObject

- (void)dealloc
{
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

#pragma mark - UIViewController  Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentSelection = [[VMultiplePickerSelection alloc] init];
    
    self.collectionView.allowsMultipleSelection = YES;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    NSAssert( self.dataSource != nil, @"A VMultiplePickerViewController must have a VCollectionToolPickerDataSource property set." );
    
    self.collectionView.dataSource = self.dataSource;
    [self.dataSource registerCellsWithCollectionView:self.collectionView];
    [self.collectionView reloadData];
    
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                      animated:NO
                                scrollPosition:UICollectionViewScrollPositionNone];
    
    [self.multiplePickerDelegate toolPicker:self didSelectItemAtIndex:0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.collectionView flashScrollIndicators];
}

#pragma mark - Selection management

- (void)itemSelectedAtIndexPath:(NSIndexPath *)indexPath
{
    [self.currentSelection indexPathWasSelected:indexPath];
    [self.collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
    [self.multiplePickerDelegate toolPicker:self didSelectItemAtIndex:indexPath.row];
}

- (void)itemDeselectedAtIndexPath:(NSIndexPath *)indexPath
{
    [self.multiplePickerDelegate toolPicker:self didDeselectItemAtIndex:indexPath.row];
    [self.currentSelection indexPathWasDeselected:indexPath];
    [self.collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
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

#pragma mark - VCollectionToolPicker

- (void)reloadData
{
    [self.collectionView reloadData];
}

#pragma mark - VMultipleToolPickerDelegate

- (BOOL)toolIsSelectedAtIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    return [self.currentSelection isIndexPathSelected:indexPath];
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

@end
