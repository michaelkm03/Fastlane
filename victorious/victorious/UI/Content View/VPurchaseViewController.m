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
#import "VAlertController.h"

@interface VPurchaseViewController ()

@property (weak, nonatomic) VPurchaseManager *purchaseManager;
@property (weak, nonatomic) IBOutlet UIView *loadingOverlay;

@end

@implementation VPurchaseViewController

#pragma mark - View controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loadingOverlay.hidden = YES;
    
    self.purchaseManager = [VPurchaseManager sharedInstance];
    
    NSString *title = NSLocalizedString( @"PurchasePromptTitle", nil);
    [self v_addNewNavHeaderWithTitles:@[ title ]];
    
    [self.navHeaderView setRightButtonImage:[UIImage imageNamed:@"close-btn"]
                                 withAction:@selector(dismiss)
                                   onTarget:self];
    
    [self.navHeaderView setLeftButtonImage:nil withAction:nil onTarget:nil];
}

#pragma mark - Helpers

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showError:(NSError *)error withTitle:(NSString *)title
{
    NSString *message = error.localizedDescription;
    VAlertController *alertConroller = [VAlertController alertWithTitle:title message:message];
    [alertConroller addAction:[VAlertAction cancelButtonWithTitle:NSLocalizedString( @"OKButton", nil ) handler:nil]];
    [alertConroller presentInViewController:self animated:YES completion:nil];
}

#pragma mark - IB Actions

- (IBAction)restorePurchasesTapped:(id)sender
{
    self.loadingOverlay.hidden = NO;
    
    [self.purchaseManager restorePurchasesSuccess:^(NSArray *productIdentifiers)
     {
         [[VSettingManager sharedManager].voteSettings didCompletePurchaseWithProductIdentifiers:productIdentifiers];
         
         self.loadingOverlay.hidden = YES;
         [self dismissViewControllerAnimated:YES completion:nil];
     }
                                                failure:^(NSError *error)
     {
         self.loadingOverlay.hidden = YES;
         NSString *title = NSLocalizedString( @"RestorePurchasesErrorTitle", nil );
         [self showError:error withTitle:title];
     }];
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
    
    [self.purchaseManager purchaseProductWithIdentifier:productIdentifier success:^(NSArray *productIdentifiers)
     {
         [[VSettingManager sharedManager].voteSettings didCompletePurchaseWithProductIdentifiers:@[ productIdentifier ]];
         
         [self dismissViewControllerAnimated:YES completion:nil];
     }
                                  failure:^(NSError *error)
     {
         NSString *title = NSLocalizedString( @"PurchaseErrorTitle", nil );
         [self showError:error withTitle:title];
     }];
}

@end
