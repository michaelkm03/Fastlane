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
#import "VAlertController.h"
#import "VNoContentTableViewCell.h"

#define V_NO_RESET_PURCHASES 1

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

@property (nonatomic, readonly) NSString *purchaseActionCellTitle;
@property (nonatomic, strong) VFileCache *fileCache;
@property (nonatomic, strong) VPurchaseManager *purchaseManager;
@property (nonatomic, assign) BOOL isRestoringPurchases;

@end

@implementation VPurchaseSettingsViewController

#pragma mark - View controller life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.fileCache = [[VFileCache alloc] init];
    self.purchaseManager = [VPurchaseManager sharedInstance];
    
    [VNoContentTableViewCell registerNibWithTableView:self.tableView];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    [self.parentViewController v_addNewNavHeaderWithTitles:@[ @"In-App Purchases" ]];
    self.parentViewController.navHeaderView.delegate = (UIViewController<VNavigationHeaderDelegate> *)self.parentViewController;
}

#pragma mark - Helpers

- (void)restorePurchases
{
    if ( self.purchaseManager.isPurchaseRequestActive )
    {
        NSString *title = NSLocalizedString( @"RestorePurchasesErrorTitle", nil );
        NSError *error = [NSError errorWithDomain:@"" code:-1 userInfo:nil];
        [self showError:error withTitle:title];
        return;
    }
    
    self.isRestoringPurchases = YES;
    [self.tableView reloadData];
    
    [self.purchaseManager restorePurchasesSuccess:^(NSSet *restoreProductIdentifiers)
     {
         self.isRestoringPurchases = NO;
         
         if ( restoreProductIdentifiers.count == 0 )
         {
             [self showAlertWithTitle:nil message:NSLocalizedString( @"RestorePurchasesNoPurchases", nil )];
             [self.tableView reloadData];
         }
         else
         {
             NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:VPurchaseSettingsTableViewSectionPurchases];
             [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
             
             NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:VPurchaseSettingsTableViewSectionActions];
             VPurchaseActionCell *cell = (VPurchaseActionCell *)[self.tableView cellForRowAtIndexPath:indexPath];
             [cell setIsActionEnabled:!self.isRestoringPurchases withTitle:self.purchaseActionCellTitle];
         }
     }
                                          failure:^(NSError *error)
     {
         NSString *title = NSLocalizedString( @"RestorePurchasesErrorTitle", nil );
         [self showError:error withTitle:title];
         self.isRestoringPurchases = NO;
         [self.tableView reloadData];
     }];
}

- (void)showError:(NSError *)error withTitle:(NSString *)title
{
    NSString *message = error.localizedDescription;
    [self showAlertWithTitle:title message:message];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    VAlertController *alertConroller = [VAlertController alertWithTitle:title message:message];
    [alertConroller addAction:[VAlertAction cancelButtonWithTitle:NSLocalizedString( @"OKButton", nil ) handler:nil]];
    [alertConroller presentInViewController:self animated:YES completion:nil];
}

- (NSString *)purchaseActionCellTitle
{
    if ( self.isRestoringPurchases )
    {
        return NSLocalizedString( @"  Restoring...", nil);
    }
    else
    {
        return NSLocalizedString( @"Restore Purchases", nil);
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == VPurchaseSettingsTableViewSectionPurchases )
    {
        if ( self.purchaseManager.purchasedProductIdentifiers.count > 0 )
        {
            NSString *identifier = NSStringFromClass( [VPurchaseCell class] );
            VPurchaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
            NSString *productIdentifier = [self.purchaseManager.purchasedProductIdentifiers.allObjects objectAtIndex:indexPath.row];
            VProduct *product = [self.purchaseManager purchaseableProductForProductIdentifier:productIdentifier];
            VVoteType *voteType = [[VSettingManager sharedManager].voteSettings voteTypeWithProductIdentifier:productIdentifier];
            UIImage *image = [self.fileCache getImageWithName:VVoteTypeIconName forVoteType:voteType];
            [cell setProductImage:image withTitle:product.localizedTitle];
            return cell;
        }
        else
        {
            VNoContentTableViewCell *cell = [VNoContentTableViewCell createCellFromTableView:tableView];
            cell.isCentered = YES;
            [cell setMessage:@"You haven't purchased anything on this device.\nIf you've made purchases on another device, tap Restore Purchases to restore them."];
            return cell;
        }
    }
    else if ( indexPath.section == VPurchaseSettingsTableViewSectionActions )
    {
        NSString *identifier = NSStringFromClass( [VPurchaseActionCell class] );
        VPurchaseActionCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        [cell setIsActionEnabled:!self.isRestoringPurchases withTitle:self.purchaseActionCellTitle];
        if ( indexPath.row == VPurchaseSettingsActionRestore )
        {
            [cell setAction:^(VPurchaseActionCell *actionCell)
             {
                 [self restorePurchases];
             }];
        }
#ifndef V_NO_RESET_PURCHASES
        else if ( indexPath.row == VPurchaseSettingsActionReset )
        {
            NSString *title = NSLocalizedString( @"Reset Purchases", nil);
            [cell setIsActionEnabled:YES withTitle:title];
            [cell setAction:^(VPurchaseActionCell *actionCell)
             {
                 [self.purchaseManager resetPurchases];
                 NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:VPurchaseSettingsTableViewSectionPurchases];
                 [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
             }];
        }
#endif
        return cell;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == VPurchaseSettingsTableViewSectionPurchases )
    {
        return MAX( self.purchaseManager.purchasedProductIdentifiers.count, (NSUInteger)1 );
    }
    else if ( section == VPurchaseSettingsTableViewSectionActions )
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
    BOOL isNoPurchasesCell = indexPath.section == VPurchaseSettingsTableViewSectionPurchases
                                && self.purchaseManager.purchasedProductIdentifiers.count == 0;
    
    BOOL isActionCell = indexPath.section == VPurchaseSettingsTableViewSectionActions;
    
    if ( isNoPurchasesCell )
    {
        return 85.0f;
    }
    else if ( isActionCell )
    {
        return 60.0f;
    }
    else
    {
        return 60.0f;
    }
}

@end
