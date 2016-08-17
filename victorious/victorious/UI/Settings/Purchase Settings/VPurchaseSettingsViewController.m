//
//  VPurchaseSettingsViewController.m
//  victorious
//
//  Created by Patrick Lynch on 12/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPurchaseSettingsViewController.h"
#import "VPurchaseManagerType.h"
#import "VPurchaseCell.h"
#import "VPurchaseActionCell.h"
#import "VNoContentTableViewCell.h"
#import "VThemeManager.h"
#import "victorious-Swift.h"

// If this enum grows beyond 4 cases, this view controller shoud be refactored to remove
// the big if-else and switch statements in most of the methods.
typedef NS_ENUM( NSInteger, VPurchaseSettingsTableViewSections )
{
    VPurchaseSettingsTableViewSectionPurchases,
    VPurchaseSettingsTableViewSectionSubscriptions,
    VPurchaseSettingsTableViewSectionActions,
    VPurchaseSettingsTableViewSectionCount
};

typedef NS_ENUM( NSInteger, VPurchaseSettingsAction )
{
    VPurchaseSettingsActionRestore,
    VPurchaseSettingsActionManageSubcription,
#ifdef V_RESET_PURCHASES
    VPurchaseSettingsActionReset,
#endif
    VPurchaseSettingsActionCount
};

static const CGFloat kNoPurchasesCelRowlHeight      = 85.0f;
static const CGFloat kActionCellRowHeight           = 60.0f;
static const CGFloat kPurchasedItemCellRowHeight    = 60.0f;

static NSString * const kAppStoreSubscriptionSettingsURL = @"itms-apps://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions";

@interface VDependencyManager(accessors)

- (NSURL *)validationURL;

@end

@implementation VDependencyManager(accessors)

- (NSURL *)validationURL
{
    NSString *urlString = [self stringForKey:@"purchaseURL"];
    if (urlString != nil)
    {
        return [[NSURL alloc] initWithString:urlString];
    }
    return nil;
}

@end

@interface VPurchaseSettingsViewController()

@property (nonatomic, strong) id<VPurchaseManagerType> purchaseManager;
@property (nonatomic, assign) BOOL isRestoringPurchases;
@property (nonatomic, strong) NSArray *purchasedProductsIdentifiers;
@property (nonatomic, strong) VPurchaseCell *subscriptionSizingCell;

@end

@implementation VPurchaseSettingsViewController

#pragma mark - View controller life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.subscriptionSizingCell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([VPurchaseCell class]) owner:self options:nil] firstObject];
    self.subscriptionSizingCell.dependencyManager = self.dependencyManager;
    
    self.purchaseManager = [VPurchaseManager sharedInstance];
    
    [VPurchaseCell registerNibWithTableView:self.tableView];
    [VNoContentTableViewCell registerNibWithTableView:self.tableView];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadProductIdentifiers];
    [self.tableView reloadData];
}

- (void)reloadProductIdentifiers
{
    self.purchasedProductsIdentifiers = self.purchaseManager.purchasedProductIdentifiers.allObjects;
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
    [self setIsLoading:YES title:NSLocalizedString(@"ActivityRestoring", @"")];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:VPurchaseSettingsTableViewSectionActions];
    VPurchaseActionCell *cell = (VPurchaseActionCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.button.enabled = NO;
    
    void (^onRestoreComplete)() = ^
    {
        [self reloadProductIdentifiers];
        [self.tableView reloadData];
        [self setIsLoading:NO title:nil];
        cell.button.enabled = YES;
    };
    
    [self.purchaseManager restorePurchasesSuccess:^(NSSet *restoredProductIdentifiers)
     {
         self.isRestoringPurchases = NO;
         
         if ( restoredProductIdentifiers.count == 0 )
         {
             [self showAlertWithTitle:[self localizedSuccessTitleWithProductsCount:0]
                              message:[self localizedSuccessMessageWithProductsCount:0]];
             onRestoreComplete();
         }
         else if ( [restoredProductIdentifiers containsObject:[self.dependencyManager vipSubscription].productIdentifier] )
         {
             // Validate and force success since even if there's an error, we must deliver the product restores to the user
             VIPValidateSuscriptionOperation *op = [[VIPValidateSuscriptionOperation alloc] initWithUrl:self.dependencyManager.validationURL shouldForceSuccess:YES];
             [op queueWithCompletion:^(NSArray *_Nullable results, NSError *_Nullable error, BOOL cancelled)
              {
                  onRestoreComplete();
              }];
         }
         else
         {
             onRestoreComplete();
         }
     }
                                          failure:^(NSError *error)
     {
         self.isRestoringPurchases = NO;
         
         onRestoreComplete();
         
         NSString *title = NSLocalizedString( @"RestorePurchasesErrorTitle", nil );
         [self showError:error withTitle:title];
     }];
}

- (NSString *)localizedSuccessMessageWithProductsCount:(NSUInteger)count
{
    if ( count == 0 )
    {
        return NSLocalizedString( @"RestorePurchasesNoPurchases", nil );
    }
    else
    {
        return NSLocalizedString( @"RestorePurchasesSuccess", nil);
    }
}

- (NSString *)localizedSuccessTitleWithProductsCount:(NSUInteger)count
{
    if ( count == 0 )
    {
        return NSLocalizedString( @"RestorePurchasesNoPurchasesTitle", nil );
    }
    else if ( count == 1 )
    {
        return [NSString stringWithFormat:NSLocalizedString( @"RestorePurchasesSuccessTitleSingular", nil), count];
    }
    else
    {
        return [NSString stringWithFormat:NSLocalizedString( @"RestorePurchasesSuccessTitlePlural", nil), count];
    }
}

- (void)showError:(NSError *)error withTitle:(NSString *)title
{
    NSString *message = error.localizedDescription;
    [self showAlertWithTitle:title message:message];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (VProduct *)subscriptionProduct
{
    NSString *productIdentifier = [self.dependencyManager vipSubscription].productIdentifier;
    if ( productIdentifier != nil )
    {
        // We don't want to check `purchasedProductIdentifiers` because subscriptions do not
        // work by that same system that uses a local purchase record. Instead, we get the product
        // from the list of those fetched on app launch just to read the price, title and other info.
        VProduct *product = [self.purchaseManager purchaseableProductForProductIdentifier:productIdentifier];
        return product;
    }
    else
    {
        return nil;
    }
}

- (BOOL)shouldShowPurchasedSubscription
{
    BOOL isVIPSubscriber = [VCurrentUser user].isVIPSubscriber.boolValue;
    VProduct *subscriptionProduct = [self subscriptionProduct];
    return subscriptionProduct != nil && isVIPSubscriber;
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case VPurchaseSettingsTableViewSectionPurchases:
            return NSLocalizedString(@"PurchasesSettingsTitle", nil);
        case VPurchaseSettingsTableViewSectionSubscriptions:
            return NSLocalizedString(@"SubscriptionsSettingsTitle", nil);
        default:
            return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == VPurchaseSettingsTableViewSectionPurchases )
    {
        if ( self.purchasedProductsIdentifiers.count > 0 )
        {
            NSString *identifier = NSStringFromClass( [VPurchaseCell class] );
            VPurchaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
            NSString *productIdentifier = [self.purchasedProductsIdentifiers objectAtIndex:indexPath.row];
            VProduct *product = [self.purchaseManager purchaseableProductForProductIdentifier:productIdentifier];
            cell.dependencyManager = self.dependencyManager;
            [cell setProductImage:nil title:product.localizedTitle];
            return cell;
        }
        else
        {
            VNoContentTableViewCell *cell = [VNoContentTableViewCell createCellFromTableView:tableView];
            [cell setMessage:NSLocalizedString( @"SettingsRestorePurchasesPrompt", nil)];
            return cell;
        }
    }
    else if ( indexPath.section == VPurchaseSettingsTableViewSectionSubscriptions)
    {
        if ( [self shouldShowPurchasedSubscription] )
        {
            if (indexPath.row == 0)
            {
                NSString *identifier = NSStringFromClass( [VPurchaseCell class] );
                VPurchaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
                [self decorateSubscriptionCell:cell forIndexPath:indexPath];
                return cell;
            }
            else if (indexPath.row == 1)
            {
                VNoContentTableViewCell *cell = [VNoContentTableViewCell createCellFromTableView:tableView];
                [cell setMessage:NSLocalizedString( @"SettingsSubscriptionSettingsPrompt", nil)];
                return cell;
            }
        }
        else
        {
            VNoContentTableViewCell *cell = [VNoContentTableViewCell createCellFromTableView:tableView];
            [cell setMessage:NSLocalizedString( @"SettingsNoSubcriptionPrompt", nil)];
            return cell;
        }
    }
    else if ( indexPath.section == VPurchaseSettingsTableViewSectionActions )
    {
        NSString *identifier = NSStringFromClass( [VPurchaseActionCell class] );
        VPurchaseActionCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        cell.button.style = VButtonStylePrimary;
        cell.button.primaryColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
        cell.button.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
        
        if ( indexPath.row == VPurchaseSettingsActionRestore )
        {
            [cell.button setTitle:NSLocalizedString( @"SettingsRestorePurchases", nil) forState:UIControlStateNormal];
            [cell setAction:^(VPurchaseActionCell *actionCell)
             {
                 [self restorePurchases];
             }];
        }
        else if ( indexPath.row == VPurchaseSettingsActionManageSubcription )
        {
            [cell.button setTitle:NSLocalizedString( @"SettingsManageSubscriptions", nil) forState:UIControlStateNormal];
            [cell setAction:^(VPurchaseActionCell *actionCell)
             {
                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppStoreSubscriptionSettingsURL]];
             }];
        }
#ifdef V_RESET_PURCHASES
        else if ( indexPath.row == VPurchaseSettingsActionReset )
        {
            [cell.button setTitle:NSLocalizedString(@"Reset Purchases", @"") forState:UIControlStateNormal];
            [cell setAction:^(VPurchaseActionCell *actionCell)
             {
                 [[[VIPClearSubscriptionOperation alloc] init] queueWithCompletion:^(NSArray *_Nullable results, NSError *_Nullable error, BOOL cancelled)
                  {
                      [self.purchaseManager resetPurchases];
                      [self reloadProductIdentifiers];
                      [self.tableView reloadData];
                  }];
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
        return MAX( self.purchasedProductsIdentifiers.count, (NSUInteger)1 );
    }
    if ( section == VPurchaseSettingsTableViewSectionSubscriptions )
    {
        if ( [self shouldShowPurchasedSubscription] )
        {
            return 2;
        }
        else
        {
            return 1;
        }
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

- (void)decorateSubscriptionCell:(VPurchaseCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    VProduct *product = [self subscriptionProduct];
    cell.dependencyManager = self.dependencyManager;
    Subscription *vipSubscription = self.dependencyManager.vipSubscription;
    [cell setSubscriptionImage:vipSubscription.iconImage
                         title:product.localizedTitle
                localizedPrice:product.price];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    const BOOL isSubscribed = [VCurrentUser user].isVIPSubscriber.boolValue;
    const BOOL showNoSubscription = indexPath.section == VPurchaseSettingsTableViewSectionPurchases && !isSubscribed;
    const BOOL showNoProducts = indexPath.section == VPurchaseSettingsTableViewSectionPurchases && self.purchasedProductsIdentifiers.count == 0;
    const BOOL isNoContentCell = showNoSubscription || showNoProducts;
    
    if ( isNoContentCell )
    {
        return kNoPurchasesCelRowlHeight;
    }
    else if ( indexPath.section == VPurchaseSettingsTableViewSectionActions )
    {
        return kActionCellRowHeight;
    }
    else if (indexPath.row == 0 && indexPath.section == VPurchaseSettingsTableViewSectionSubscriptions && isSubscribed)
    {
        // Only the subscription cell uses dynamic height calculated in `cellSizeWithinBounds:`
        [self decorateSubscriptionCell:self.subscriptionSizingCell forIndexPath:indexPath];
        return [self.subscriptionSizingCell cellSizeWithinBounds:tableView.bounds].height;
    }
    else
    {
        return kPurchasedItemCellRowHeight;
    }
}

@end
