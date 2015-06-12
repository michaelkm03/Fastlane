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
#import "VCreateSheetAnimator.h"
#import "VDependencyManager+VStatusBarStyle.h"

static NSString * const kCreateImageIdentifier = @"Create Image";
static NSString * const kCreateVideoIdentifier = @"Create Video";
static NSString * const kCreatePollIdentifier = @"Create Poll";
static NSString * const kCreateMemeIdentifier = @"Create Meme";
static NSString * const kCreateGIFIdentifier = @"Create GIF";

static NSString * const kStoryboardName = @"CreateSheet";
static NSString * const kStatusBarStyleKey = @"statusBarStyle";

static const CGFloat kLineSpacing = 20.0f;

@interface VCreateSheetViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) VDependencyManager *dependencyManager;
@property (strong, nonatomic) VCreateSheetTransitionDelegate *transitionDelegate;
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

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.modalPresentationStyle = UIModalPresentationCustom;
        _transitionDelegate = [[VCreateSheetTransitionDelegate alloc] init];
        self.transitioningDelegate = _transitionDelegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set delegate and data source
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    // Make cells respond immediately to touch
    self.collectionView.delaysContentTouches = NO;
    
    // Setup dismiss button
    [self.dismissButton.titleLabel setFont:[self.dependencyManager fontForKey:VDependencyManagerHeading4FontKey]];
    [self.dismissButton setTitleColor:[self.dependencyManager colorForKey:VDependencyManagerLinkColorKey] forState:UIControlStateNormal];
    [self.dismissButton setBackgroundColor:[self.dependencyManager colorForKey:VDependencyManagerAccentColorKey]];
    
    // Set line height and item size for flow layout
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(CGRectGetWidth(self.view.bounds), [VCreateSheetCollectionViewCell cellHeight]);
    [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setMinimumLineSpacing:kLineSpacing];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [self.dependencyManager statusBarStyleForKey:kStatusBarStyleKey];
}

#pragma mark - Properties

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    // Setup menu items
    self.menuItems = [dependencyManager menuItems];
    [self.transitionDelegate setDependencyManager:dependencyManager];
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

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    NSInteger numberOfCells = [self.menuItems count];
    
    CGFloat contentHeight = numberOfCells * [VCreateSheetCollectionViewCell cellHeight] + (numberOfCells - 1) * kLineSpacing;
    
    if (contentHeight >= CGRectGetHeight(collectionView.frame))
    {
        return UIEdgeInsetsZero;
    }
    
    // Center content in middle of collection view
    NSInteger verticalInset = (CGRectGetHeight(collectionView.frame) - contentHeight) / 2;
    return UIEdgeInsetsMake(verticalInset, 0, verticalInset, 0);
}

@end
