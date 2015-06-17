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
#import "VCreateSheetTransitionDelegate.h"
#import "VDependencyManager+VStatusBarStyle.h"

static NSString * const kCreateImageIdentifier = @"Create Image";
static NSString * const kCreateVideoIdentifier = @"Create Video";
static NSString * const kCreatePollIdentifier = @"Create Poll";
static NSString * const kCreateMemeIdentifier = @"Create Text";
static NSString * const kCreateGIFIdentifier = @"Create GIF";

static NSString * const kStoryboardName = @"CreateSheet";
static NSString * const kStatusBarStyleKey = @"statusBarStyle";
static NSString * const kDismissButtonTitle = @"title.button1";

static const CGFloat kLineSpacing = 40.0f;

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
        [self setModalPresentationStyle:UIModalPresentationCustom];
        _transitionDelegate = [[VCreateSheetTransitionDelegate alloc] init];
        [self setTransitioningDelegate:_transitionDelegate];
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
    
    // So cells don't get cut off while animating
    self.collectionView.clipsToBounds = NO;
    
    // Setup dismiss button
    [self.dismissButton setTitle:NSLocalizedString([self.dependencyManager stringForKey:kDismissButtonTitle], @"") forState:UIControlStateNormal];
    [self.dismissButton.titleLabel setFont:[self.dependencyManager fontForKey:VDependencyManagerHeading4FontKey]];
    [self.dismissButton setTitleColor:[self.dependencyManager colorForKey:VDependencyManagerLinkColorKey] forState:UIControlStateNormal];
    [self.dismissButton setBackgroundColor:[self.dependencyManager colorForKey:VDependencyManagerAccentColorKey]];
    
    // Shadow
    self.dismissButton.layer.masksToBounds = YES;
    self.dismissButton.layer.shadowOffset = CGSizeMake(0, -kShadowOffset);
    self.dismissButton.layer.shadowRadius = 1;
    self.dismissButton.layer.shadowOpacity = 0.4f;
    self.dismissButton.layer.masksToBounds = NO;
    
    // Set line height and item size for flow layout
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    [layout setMinimumLineSpacing:kLineSpacing];
    
    // Collection view background
    UIView *collectionViewBackground = [UIView new];
    collectionViewBackground.backgroundColor = [UIColor clearColor];
    [self.collectionView setBackgroundView:collectionViewBackground];
    [self.collectionView.backgroundView setUserInteractionEnabled:YES];
    
    // Tap gesture for dismissal
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBackground:)];
    [self.collectionView.backgroundView addGestureRecognizer:tapGesture];
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

- (void)tappedBackground:(UITapGestureRecognizer *)tap
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
    cell.itemLabel.text = NSLocalizedString(menuItem.title, @"");
    cell.itemLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeading1FontKey];
    cell.itemLabel.textColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    [cell.iconImageView setImage:[menuItem.icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    cell.iconImageView.tintColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    
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
        return VCreateSheetItemIdentifierText;
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
    VNavigationMenuItem *menuItem = self.menuItems[indexPath.row];
    return CGSizeMake(CGRectGetWidth(self.view.bounds) - 80, [self heightForMenuItemTitle:menuItem.title]);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    NSInteger numberOfCells = [self.menuItems count];
    
    CGFloat totalCellHeight = 0;
    for (VNavigationMenuItem *item in self.menuItems)
    {
        totalCellHeight += [self heightForMenuItemTitle:item.title];
    }
    
    CGFloat contentHeight = totalCellHeight + (numberOfCells - 1) * kLineSpacing;
    
    if (contentHeight >= CGRectGetHeight(collectionView.frame))
    {
        // Add some padding if collection view contents are larger than screen bounds
        return UIEdgeInsetsMake(40, 0, 20, 0);
    }
    
    // Center content in middle of collection view
    CGFloat statusBarHeight = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    NSInteger verticalInset = (CGRectGetHeight(collectionView.bounds) - contentHeight - statusBarHeight) / 2;
    return UIEdgeInsetsMake(verticalInset, 0, verticalInset, 0);
}

#pragma mark - Helpers

- (CGFloat)heightForMenuItemTitle:(NSString *)text
{
    UIFont *font = [self.dependencyManager fontForKey:VDependencyManagerHeading1FontKey];
    CGRect minimumFrame = [text boundingRectWithSize:CGSizeMake(CGRectGetHeight(self.view.bounds), CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{ NSFontAttributeName : font }
                                             context:nil];
    return VCEIL(CGRectGetHeight(minimumFrame));
}

@end
