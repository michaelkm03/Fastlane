//
//  VMenuController.m
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSArray+VMap.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "VDependencyManager+VNavigationMenuItem.h"
#import "VDependencyManager+VScaffoldViewController.h"
#import "VMenuCollectionViewCell.h"
#import "VMenuCollectionViewDataSource.h"
#import "VMenuController.h"
#import "VNavigationMenuItem.h"

#import "VThemeManager.h"
#import "VObjectManager.h"
#import "VScaffoldViewController.h"
#import "VSettingManager.h"

#import "VStream+Fetcher.h"

#import "VLoginViewController.h"
#import "VUserProfileViewController.h"
#import "VSettingsViewController.h"
#import "VInboxContainerViewController.h"
#import "VUserProfileNavigationDestination.h"
#import "VDirectoryViewController.h"
#import "VGroupedStreamCollectionViewController.h"
#import "VDiscoverContainerViewController.h"

#import "VStreamCollectionViewController.h"

static NSString * const kSectionHeaderReuseID = @"SectionHeaderView";
static const CGFloat kSectionHeaderHeight = 36.0f;
static char kKVOContext;

@interface VMenuController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) VMenuCollectionViewDataSource *collectionViewDataSource;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

#pragma mark properties for VProvidesNavigationMenuItemBadge compliance

@property (nonatomic) NSInteger badgeNumber;
@property (nonatomic, copy) VNavigationMenuItemBadgeNumberUpdateBlock badgeNumberUpdateBlock;

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
    
    // Set the initial section in tracking session parameters
    VNavigationMenuItem *menuItem = [self.collectionViewDataSource menuItemAtIndexPath:0];
    [[VTrackingManager sharedInstance] setValue:menuItem.title forSessionParameterWithKey:VTrackingKeyCurrentSection];
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

#pragma mark - VNavigationDestinationsProvider methodsm

- (NSArray *)navigationDestinations
{
    return [[self.dependencyManager menuItemSections] v_flatMap:^NSArray *(NSArray *section)
    {
        return [section v_map:^id(VNavigationMenuItem *item)
        {
            return item.destination;
        }];
    }];
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
    VNavigationMenuItem *menuItem = [self.collectionViewDataSource menuItemAtIndexPath:indexPath];
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSDictionary *params = @{ VTrackingKeyMenuType : VTrackingValueHamburgerMenu, VTrackingKeySection : menuItem.title };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectMainSection parameters:params];
    
    [[self.dependencyManager scaffoldViewController] navigateToDestination:menuItem.destination completion:^void
     {
         [[VTrackingManager sharedInstance] setValue:menuItem.title forSessionParameterWithKey:VTrackingKeyCurrentSection];
     }];
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
            self.badgeNumber = [newBadgeTotal integerValue];
            
            if ( self.badgeNumberUpdateBlock != nil )
            {
                self.badgeNumberUpdateBlock(self.badgeNumber);
            }
        }
    }
}

@end
