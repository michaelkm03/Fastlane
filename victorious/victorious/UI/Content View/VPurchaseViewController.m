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
#import "VThemeManager.h"

@interface VPurchaseViewController ()

@property (strong, nonatomic) VPurchaseManager *purchaseManager;
@property (strong, nonatomic) VProduct *product;

@property (weak, nonatomic) IBOutlet UIView *loadingOverlay;
@property (weak, nonatomic) IBOutlet UILabel *loadingOverlayLabel;

@property (weak, nonatomic) IBOutlet UILabel *producttitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *productDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *productImage;

@property (weak, nonatomic) IBOutlet UIButton *unlockButton;

@end

@implementation VPurchaseViewController

#pragma mark - View controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loadingOverlay.hidden = YES;
    
    self.purchaseManager = [VPurchaseManager sharedInstance];
    
    self.product = [self.purchaseManager purcahseableProductForProductIdenfitier:self.voteType.productIdentifier];
    
    NSString *localizedFormat = NSLocalizedString( @"PurchaseUnlockWithPrice", nil);
    NSString *unlockTitle = [NSString stringWithFormat:localizedFormat, self.product.price];
    [self.unlockButton setTitle:unlockTitle forState:UIControlStateNormal];
    self.unlockButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
}

#pragma mark - Helpers

- (void)showLoadingOverlayWithLabelText:(NSString *)text
{
    self.loadingOverlayLabel.text = text;
    self.loadingOverlay.hidden = NO;
}

- (void)hideLoadingOverlay
{
    self.loadingOverlayLabel.text = @"";
    self.loadingOverlay.hidden = YES;
}
- (void)showError:(NSError *)error withTitle:(NSString *)title
{
    NSString *message = error.localizedDescription;
    VAlertController *alertConroller = [VAlertController alertWithTitle:title message:message];
    [alertConroller addAction:[VAlertAction cancelButtonWithTitle:NSLocalizedString( @"OKButton", nil ) handler:nil]];
    [alertConroller presentInViewController:self animated:YES completion:nil];
}

#pragma mark - IB Actions

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)restorePurchasesTapped:(id)sender
{
    [self showLoadingOverlayWithLabelText:NSLocalizedString( @"ActivityRestoring", nil)];
    
    [self.purchaseManager restorePurchasesSuccess:^(NSArray *productIdentifiers)
     {
         [[VSettingManager sharedManager].voteSettings didCompletePurchaseWithProductIdentifiers:productIdentifiers];
         
         [self hideLoadingOverlay];
         [self dismissViewControllerAnimated:YES completion:nil];
     }
                                                failure:^(NSError *error)
     {
         [self hideLoadingOverlay];
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
    
    [self showLoadingOverlayWithLabelText:NSLocalizedString( @"ActivityPurchasing", nil)];
    
    NSString *productIdentifier = self.voteType.productIdentifier;
    [self.purchaseManager purchaseProductWithIdentifier:productIdentifier success:^(NSArray *productIdentifiers)
     {
         [[VSettingManager sharedManager].voteSettings didCompletePurchaseWithProductIdentifiers:@[ productIdentifier ]];
         
         [self hideLoadingOverlay];
         [self dismissViewControllerAnimated:YES completion:nil];
     }
                                  failure:^(NSError *error)
     {
         [self hideLoadingOverlay];
         // If error is nil, the user cancelled the purchase
         if ( error != nil )
         {
             NSString *title = NSLocalizedString( @"PurchaseErrorTitle", nil );
             [self showError:error withTitle:title];
         }
     }];
}

@end
