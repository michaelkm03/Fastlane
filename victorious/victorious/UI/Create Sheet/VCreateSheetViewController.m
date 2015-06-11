//
//  VCreateSheetViewController.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 6/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCreateSheetViewController.h"
#import "VCreateSheetCollectionViewCell.h"
#import "VDependencyManager.h"
#import "VDependencyManager+VNavigationMenuItem.h"
#import "VNavigationMenuItem.h"

static NSString * const kCreateImageIdentifier = @"Create Image";
static NSString * const kCreateVideoIdentifier = @"Create Video";
static NSString * const kCreatePollIdentifier = @"Create Poll";
static NSString * const kCreateMemeIdentifier = @"Create Meme";
static NSString * const kCreateGIFIdentifier = @"Create GIF";

static NSString * const kStoryboardName = @"CreateSheet";
static NSString * const kMenuItemKey = @"menuItems";

static const CGFloat kLineSpacing = 20.0f;

@interface VCreateSheetViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) VDependencyManager *dependencyManager;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@property (strong, nonatomic) NSArray *menuItems;

@end

@implementation VCreateSheetViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryboardName bundle:nil];
    VCreateSheetViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    viewController.dependencyManager = dependencyManager;
    return viewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.collectionView.delaysContentTouches = NO;
    
    [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setMinimumLineSpacing:kLineSpacing];
}

#pragma mark - Properties

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    self.menuItems = [dependencyManager menuItems];
}

#pragma mark - Actions

- (IBAction)pressedDismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.menuItems count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VNavigationMenuItem *menuItem = self.menuItems[indexPath.row];
    
    VCreateSheetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"createSheetCell" forIndexPath:indexPath];
    cell.itemLabel.text = menuItem.title;
    cell.itemLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeading1FontKey];
    cell.itemLabel.textColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    
    return cell;
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VNavigationMenuItem *menuItem = self.menuItems[indexPath.row];
    
    if (self.completionHandler != nil)
    {
        self.completionHandler(self, [self itemIdentifierFromString:menuItem.identifier]);
    }
}


- (VCreateSheetItemIdentifier)itemIdentifierFromString:(NSString *)identifierString
{
    if ([identifierString isEqualToString:kCreateImageIdentifier])
    {
        return VCreateSheetItemIdentifierImage;
    }
    else if ([identifierString isEqualToString:kCreateVideoIdentifier])
    {
        return VCreateSheetItemIdentifierVideo;
    }
    else if ([identifierString isEqualToString:kCreatePollIdentifier])
    {
        return VCreateSheetItemIdentifierPoll;
    }
    else if ([identifierString isEqualToString:kCreateMemeIdentifier])
    {
        return VCreateSheetItemIdentifierMeme;
    }
    else if ([identifierString isEqualToString:kCreateGIFIdentifier])
    {
        return VCreateSheetItemIdentifierGIF;
    }
    
    return VCreateSheetItemIdentifierUnknown;
}

#pragma mark - Flow Layout Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(collectionView.bounds), [VCreateSheetCollectionViewCell cellHeight]);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    NSInteger numberOfCells = [self.menuItems count];
    
    CGFloat contentHeight = numberOfCells * [VCreateSheetCollectionViewCell cellHeight] + (numberOfCells - 1) * kLineSpacing;
    
    if (contentHeight >= CGRectGetHeight(collectionView.bounds))
    {
        return UIEdgeInsetsZero;
    }
    
    // Center content in middle of collection view
    NSInteger verticalInset = (CGRectGetHeight(collectionView.bounds) - contentHeight) / 2;
    return UIEdgeInsetsMake(verticalInset, 0, verticalInset, 0);
}

@end
