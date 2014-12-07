//
//  VMenuController.m
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIStoryboard+VMainStoryboard.h"
#import "VDependencyManager+VNavigationMenuItem.h"
#import "VMenuCollectionViewCell.h"
#import "VMenuCollectionViewDataSource.h"
#import "VMenuController.h"
#import "VNavigationMenuItem.h"

#import "VThemeManager.h"
#import "VObjectManager.h"
#import "VSettingManager.h"

#import "VStream+Fetcher.h"

#import "VLoginViewController.h"
#import "VUserProfileViewController.h"
#import "VSettingsViewController.h"
#import "VInboxContainerViewController.h"
#import "VUserProfileNavigationDestination.h"
#import "VAuthorizationViewControllerFactory.h"
#import "VDirectoryViewController.h"
#import "VDiscoverContainerViewController.h"

#import "VStreamCollectionViewController.h"
#import "VMultipleStreamViewController.h"

NSString * const VMenuControllerDidSelectRowNotification = @"VMenuTableViewControllerDidSelectRowNotification";
NSString * const VMenuControllerDestinationViewControllerKey = @"VMenuControllerDestinationViewControllerKey";

static NSString * const kSectionHeaderReuseID = @"SectionHeaderView";
static const CGFloat kSectionHeaderHeight = 36.0f;
static char kKVOContext;

@interface VMenuController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) VMenuCollectionViewDataSource *collectionViewDataSource;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VMenuController

#pragma mark VHasManagedDependencies conforming initializer

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VMenuController *menuController = [[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:NSStringFromClass([VMenuController class])];
    menuController.dependencyManager = dependencyManager;
    return menuController;
}

#pragma mark -

- (void)dealloc
{
    if ( _collectionViewDataSource != nil )
    {
        [_collectionViewDataSource removeObserver:self forKeyPath:NSStringFromSelector(@selector(badgeTotal)) context:&kKVOContext];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionViewDataSource = [[VMenuCollectionViewDataSource alloc] initWithCellReuseID:[VMenuCollectionViewCell suggestedReuseIdentifier]
                                                                           sectionsOfMenuItems:[self.dependencyManager menuItemSections]];
    self.collectionViewDataSource.dependencyManager = self.dependencyManager;
    self.collectionViewDataSource.sectionHeaderReuseID = kSectionHeaderReuseID;
    self.collectionView.dataSource = self.collectionViewDataSource;
    [self.collectionViewDataSource addObserver:self
                                    forKeyPath:NSStringFromSelector(@selector(badgeTotal))
                                       options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                                       context:&kKVOContext];
    
    if ([[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled])
    {
        self.view.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    }
    else
    {
        self.view.backgroundColor = [UIColor clearColor];
    }
}

- (void)viewDidLayoutSubviews
{
    CGFloat extraSpace = CGRectGetHeight(self.view.bounds) - self.collectionView.contentSize.height;
    UIEdgeInsets desiredInsets = UIEdgeInsetsZero;
    
    if (extraSpace > 0)
    {
        desiredInsets = UIEdgeInsetsMake(extraSpace * 0.5f, 0.0f, extraSpace * 0.5f, 0.0);
    }
    
    if ( !UIEdgeInsetsEqualToEdgeInsets(desiredInsets, self.collectionView.contentInset) )
    {
        self.collectionView.contentInset = desiredInsets;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [VMenuCollectionViewCell desiredSizeWithCollectionViewBounds:collectionView.bounds];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return CGSizeZero;
    }
    else
    {
        return CGSizeMake(CGRectGetHeight(collectionView.bounds), kSectionHeaderHeight);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];

    VNavigationMenuItem *menuItem = [self.collectionViewDataSource menuItemAtIndexPath:indexPath];
    [[NSNotificationCenter defaultCenter] postNotificationName:VMenuControllerDidSelectRowNotification object:self userInfo:@{ VMenuControllerDestinationViewControllerKey: menuItem.destination }];
}

#pragma mark - Key-Value Observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( context != &kKVOContext )
    {
        return;
    }
    
    if ( object == self.collectionViewDataSource && [keyPath isEqualToString:NSStringFromSelector(@selector(badgeTotal))] )
    {
        NSNumber *newBadgeTotal = change[NSKeyValueChangeNewKey];
        
        if ( [newBadgeTotal isKindOfClass:[NSNumber class]] )
        {
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[newBadgeTotal integerValue]];
        }
    }
}

@end
