//
//  VPurchaseViewController.m
//  victorious
//
//  Created by Patrick Lynch on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPurchaseViewController.h"
#import "UIViewController+VNavMenu.h"
#import "VPurchaseManager.h"
#import "VSettingManager.h"

@interface VPurchaseViewController ()

@property (nonatomic, strong) VPurchaseManager *purchaseManager;

@end

@implementation VPurchaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.purchaseManager = [VPurchaseManager sharedInstance];
    
    NSString *title = NSLocalizedString( @"Buy This Emotive Ballstic", nil);
    [self v_addNewNavHeaderWithTitles:@[ title ]];
    
    [self.navHeaderView setRightButtonImage:[UIImage imageNamed:@"close-btn"]
                                 withAction:@selector(dismiss)
                                   onTarget:self];
    
    [self.navHeaderView setLeftButtonImage:nil withAction:nil onTarget:nil];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)buyTapped:(id)sender
{
    if ( self.voteType == nil )
    {
        return;
    }
    
    NSString *productIdentifier = self.voteType.productIdentifier;
    if ( productIdentifier == nil )
    {
        return;
    }
    
    [self.purchaseManager purchaseProductWithIdentifier:productIdentifier success:^(NSArray *products)
     {
         [[VSettingManager sharedManager] updateSettingsWithPurchasedProductIdentifier:productIdentifier];
         [self dismissViewControllerAnimated:YES completion:nil];
     }
                                  failure:^(NSError *error)
     {
         
     }];
}

@end
