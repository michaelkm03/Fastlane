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

typedef NS_ENUM( NSInteger, VPurchaseSettingsTableViewSections )
{
    VPurchaseSettingsTableViewSectionPurchases,
    VPurchaseSettingsTableViewSectionActions,
    VPurchaseSettingsTableViewSectionCount
};

@interface VPurchaseSettingsViewController()

@property (nonatomic, strong) VPurchaseManager *purchaseManager;

@end

@implementation VPurchaseSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.purchaseManager = [VPurchaseManager sharedInstance];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    [self.parentViewController v_addNewNavHeaderWithTitles:nil];
    self.parentViewController.navHeaderView.delegate = (UIViewController<VNavigationHeaderDelegate> *)self.parentViewController;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section ==  VPurchaseSettingsTableViewSectionPurchases )
    {
        NSString *identifier = NSStringFromClass( [VPurchaseCell class] );
        VPurchaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        NSString *productIdentifier = self.purchaseManager purch
        VProduct *product = [self.purchaseManager purchaseableProductForProductIdentifier:productIdentifier];
        return cell;
    }
    else if ( indexPath.section ==  VPurchaseSettingsTableViewSectionActions )
    {
        NSString *identifier = NSStringFromClass( [VPurchaseActionCell class] );
        VPurchaseActionCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        
        return cell;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section ==  VPurchaseSettingsTableViewSectionPurchases )
    {
        return [self.purchaseManager numberOfPurchasedItems];
    }
    else if ( section ==  VPurchaseSettingsTableViewSectionActions )
    {
        return 2;
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return VPurchaseSettingsTableViewSectionCount;
}

#pragma mark - UITableViewDataSource

@end
