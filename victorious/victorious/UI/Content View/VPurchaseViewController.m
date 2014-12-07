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
#import "VButton.h"
#import "VLoadingOverlayViewController.h"

@interface VPurchaseViewController ()

@property (strong, nonatomic) VPurchaseManager *purchaseManager;
@property (strong, nonatomic) VProduct *product;
@property (strong, nonatomic) VLoadingOverlayViewController *loadingOverlay;

@property (weak, nonatomic) IBOutlet UILabel *productTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *createNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *productDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *productImage;

@property (weak, nonatomic) IBOutlet VButton *unlockButton;
@property (weak, nonatomic) IBOutlet VButton *restoreButton;

@end

@implementation VPurchaseViewController

#pragma mark - Initialization

+ (VPurchaseViewController *)instantiateFromStoryboard:(NSString *)storyboardName withVoteType:(VVoteType *)voteType
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    NSString *identifier = NSStringFromClass( [VPurchaseViewController class] );
    VPurchaseViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    viewController.voteType = voteType;
    return viewController;
}

#pragma mark - View controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.purchaseManager = [VPurchaseManager sharedInstance];
    self.product = [self.purchaseManager purcahseableProductForProductIdenfitier:self.voteType.productIdentifier];
    
    self.loadingOverlay = [VLoadingOverlayViewController instantiateFromStoryboard:@"ContentView"];
    [self.loadingOverlay configureForUseInViewController:self];
    
    [self applyTheme];
    
    [self populateDataWithProduct:self.product];
}

- (void)populateDataWithProduct:(VProduct *)product
{
    NSString *localizedFormat = NSLocalizedString( @"PurchaseUnlockWithPrice", nil);
    NSString *unlockTitle = [NSString stringWithFormat:localizedFormat, product.price];
    [self.unlockButton setTitle:unlockTitle forState:UIControlStateNormal];
    
    self.productTitleLabel.text = product.localizedTitle;
    self.productDescriptionTextView.text = product.localizedDescription;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Theme

- (void)applyTheme
{
    self.unlockButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.unlockButton.titleLabel.font = [UIFont fontWithName:@"MuseoSans-300" size:18.0f];
    self.unlockButton.style = VButtonStylePrimary;
    
    self.restoreButton.titleLabel.font = [UIFont fontWithName:@"MuseoSans-300" size:15.0f];
    self.restoreButton.style = VButtonStyleSecondary;
    
    self.productDescriptionTextView.font = [UIFont fontWithName:@"MuseoSans-300" size:17.0f];
    self.productTitleLabel.font = [UIFont fontWithName:@"MuseoSans-500" size:15.0f];
}

#pragma mark - Helpers

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
    [self.loadingOverlay showWithText:NSLocalizedString( @"ActivityRestoring", nil) animated:YES];
    
    [self.purchaseManager restorePurchasesSuccess:^(NSArray *productIdentifiers)
     {
         [[VSettingManager sharedManager].voteSettings didCompletePurchaseWithProductIdentifiers:productIdentifiers];
         
         [self.loadingOverlay hideAnimated:YES];
         [self dismissViewControllerAnimated:YES completion:nil];
     }
                                                failure:^(NSError *error)
     {
         [self.loadingOverlay hideAnimated:YES];
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
    
    [self.loadingOverlay showWithText:NSLocalizedString( @"ActivityPurchasing", nil) animated:YES];
    
    NSString *productIdentifier = self.voteType.productIdentifier;
    [self.purchaseManager purchaseProductWithIdentifier:productIdentifier success:^(NSArray *productIdentifiers)
     {
         [[VSettingManager sharedManager].voteSettings didCompletePurchaseWithProductIdentifiers:@[ productIdentifier ]];
         
         [self.loadingOverlay hideAnimated:YES];
         [self dismissViewControllerAnimated:YES completion:nil];
     }
                                  failure:^(NSError *error)
     {
         [self.loadingOverlay hideAnimated:YES];
         // If error is nil, the user cancelled the purchase
         if ( error != nil )
         {
             NSString *title = NSLocalizedString( @"PurchaseErrorTitle", nil );
             [self showError:error withTitle:title];
         }
     }];
}

@end
