//
//  VPurchaseSettingsViewController.m
//  victorious
//
//  Created by Patrick Lynch on 12/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPurchaseSettingsViewController.h"
#import "UIViewController+VNavMenu.h"
#import "VPurchaseManager.h"
#import "VPurchaseCell.h"
#import "VPurchaseActionCell.h"
#import "VFileCache.h"
#import "VFileCache+VVoteType.h"
#import "VSettingManager.h"

typedef NS_ENUM( NSInteger, VPurchaseSettingsTableViewSections )
{
    VPurchaseSettingsTableViewSectionPurchases,
    VPurchaseSettingsTableViewSectionActions,
    VPurchaseSettingsTableViewSectionCount
};

typedef NS_ENUM( NSInteger, VPurchaseSettingsAction )
{
    VPurchaseSettingsActionRestore,
#ifndef V_NO_RESET_PURCHASES
    VPurchaseSettingsActionReset,
#endif
    VPurchaseSettingsActionCount
};

@interface VPurchaseSettingsViewController()

@property (nonatomic, strong) VFileCache *fileCache;
@property (nonatomic, strong) VPurchaseManager *purchaseManager;

@end

@implementation VPurchaseSettingsViewController

#pragma mark - View controller life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.fileCache = [[VFileCache alloc] init];
    self.purchaseManager = [VPurchaseManager sharedInstance];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    [self.parentViewController v_addNewNavHeaderWithTitles:nil];
    self.parentViewController.navHeaderView.delegate = (UIViewController<VNavigationHeaderDelegate> *)self.parentViewController;
}

#pragma mark - Helpers

- (void)restorePurchases
{
    [self.purchaseManager restorePurchasesSuccess:^(NSArray *restoredProducts)
     {
         [self.tableView reloadData];
     }
                                          failure:^(NSError *error)
     {
         
     }];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section ==  VPurchaseSettingsTableViewSectionPurchases )
    {
        NSString *identifier = NSStringFromClass( [VPurchaseCell class] );
        VPurchaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        NSString *productIdentifier = [self.purchaseManager.purchasedProductIdentifiers objectAtIndex:indexPath.row];
        VProduct *product = [self.purchaseManager purchaseableProductForProductIdentifier:productIdentifier];
        VVoteType *voteType = [[VSettingManager sharedManager].voteSettings voteTypeWithProductIdentifier:productIdentifier];
        UIImage *image = [self.fileCache getImageWithName:VVoteTypeIconLargeName forVoteType:voteType];
        [cell setProductImage:image withTitle:product.localizedTitle];
        return cell;
    }
    else if ( indexPath.section ==  VPurchaseSettingsTableViewSectionActions )
    {
        NSString *identifier = NSStringFromClass( [VPurchaseActionCell class] );
        VPurchaseActionCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        if ( indexPath.row == VPurchaseSettingsActionRestore )
        {
            [cell setAction:^(VPurchaseActionCell *actionCell)
             {
                 [self restorePurchases];
                
            } withTitle:NSLocalizedString( @"Restore Purchases", nil)];
        }
#ifndef V_NO_RESET_PURCHASES
        else if ( indexPath.row == VPurchaseSettingsActionReset )
        {
            [cell setAction:^(VPurchaseActionCell *actionCell)
             {
                 [self.purchaseManager resetPurchases];
                 [self.tableView reloadData];
                 
             } withTitle:NSLocalizedString( @"Reset Purchases", nil)];
        }
#endif
        return cell;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section ==  VPurchaseSettingsTableViewSectionPurchases )
    {
        return self.purchaseManager.purchasedProductIdentifiers.count;
    }
    else if ( section ==  VPurchaseSettingsTableViewSectionActions )
    {
        return VPurchaseSettingsActionCount;
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return VPurchaseSettingsTableViewSectionCount;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section ==  VPurchaseSettingsTableViewSectionActions )
    {
        return 44.0;
    }
    else
    {
        return 60.0f;
    }
}

@end
