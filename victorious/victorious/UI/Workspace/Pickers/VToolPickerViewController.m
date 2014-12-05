//
//  VToolPickerViewontroller.m
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VToolPickerViewController.h"
#import "VBasicToolPickerCell.h"

@interface VToolPickerViewController ()

@end

@implementation VToolPickerViewController

@synthesize tools = _tools;
@synthesize onToolSelection = _onToolSelection;

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *workspaceStoryboard = [UIStoryboard storyboardWithName:@"Workspace"
                                                                  bundle:nil];
    VToolPickerViewController *toolPicker = [workspaceStoryboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    toolPicker.clearsSelectionOnViewWillAppear = NO;
    return toolPicker;
}

#pragma mark - UIViewController
#pragma mark Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.allowsMultipleSelection = NO;
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
    pickerCell.label.text = toolForIndexPath.title;
    
    return pickerCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.onToolSelection)
    {
        self.onToolSelection([self selectedTool]);
    }
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

@end
