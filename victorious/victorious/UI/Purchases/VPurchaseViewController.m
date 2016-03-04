//
//  VPurchaseViewController.m
//  victorious
//
//  Created by Patrick Lynch on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPurchaseViewController.h"
#import "VPurchaseManager.h"
#import "VThemeManager.h"
#import "VButton.h"
#import "VPurchaseStringMaker.h"
#import "VDependencyManager.h"
#import "VCreatorInfoHelper.h"

static const CGFloat kRestorePurchaseDescriptionFontSize = 11.0f;
static const CGFloat kRestorePurchaseDescriptionGrayLevel = 0.557f;

@interface VPurchaseViewController ()

@property (strong, nonatomic) VPurchaseManager *purchaseManager;
@property (strong, nonatomic) VProduct *product;
@property (strong, nonatomic) VPurchaseStringMaker *stringMaker;
@property (strong, nonatomic) VDependencyManager *dependencyManager;

@property (weak, nonatomic) IBOutlet VCreatorInfoHelper *creatorInfoHelper;
@property (weak, nonatomic) IBOutlet UILabel *productTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *productDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UIView *unlockLoadingView;
@property (weak, nonatomic) IBOutlet UILabel *unlockLoadingLabel;
@property (weak, nonatomic) IBOutlet UIView *restoreLoadingView;
@property (weak, nonatomic) IBOutlet UILabel *restoreLoadingLabel;
@property (weak, nonatomic) IBOutlet VButton *unlockButton;
@property (weak, nonatomic) IBOutlet VButton *restoreButton;
@property (weak, nonatomic) IBOutlet UITextView *restoreDescriptionTextView;

@end

@implementation VPurchaseViewController

#pragma mark - Initialization

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
                       productIdentifier:(NSString *)productIdentifier
                               largeIcon:(UIImage *)largeIcon
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Purchases" bundle:[NSBundle mainBundle]];
    VPurchaseViewController *viewController = [storyboard instantiateInitialViewController];
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    viewController.dependencyManager = dependencyManager;
    viewController.productIdentifier = productIdentifier;
    viewController.largeIcon = largeIcon;
    return viewController;
}

#pragma mark - View controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.restoreDescriptionTextView.attributedText = [[NSAttributedString alloc]
                                                      initWithString:NSLocalizedString(@"RestorePurchaseDescription", @"")
                                                      attributes:[self attributesForRestoreDescription]];
    self.purchaseManager = [VPurchaseManager sharedInstance];
    self.stringMaker = [[VPurchaseStringMaker alloc] init];
    self.product = [self.purchaseManager purchaseableProductForProductIdentifier:self.productIdentifier];
    
    [self resetLoadingState];
    
    [self.creatorInfoHelper populateViewsWithDependencyManager:self.dependencyManager];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Helpers

- (NSDictionary *)attributesForRestoreDescription
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    return @{ NSFontAttributeName: [UIFont systemFontOfSize:kRestorePurchaseDescriptionFontSize],
              NSForegroundColorAttributeName:[UIColor colorWithRed:kRestorePurchaseDescriptionGrayLevel
                                                             green:kRestorePurchaseDescriptionGrayLevel
                                                              blue:kRestorePurchaseDescriptionGrayLevel
                                                             alpha:1.0f],
              NSParagraphStyleAttributeName: paragraphStyle,
             };
}

- (void)applyTheme
{
    UIColor *linkColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    
    NSString *fontNameRegular = @"MuseoSans-300";
    
    self.unlockButton.primaryColor = linkColor;
    self.unlockButton.titleLabel.font = [UIFont fontWithName:fontNameRegular size:18.0f];
    self.unlockButton.style = VButtonStylePrimary;
    
    self.unlockButton.primaryColor = linkColor;
    self.restoreButton.titleLabel.font = [UIFont fontWithName:fontNameRegular size:15.0f];
    self.restoreButton.style = VButtonStyleSecondary;
    
    self.productDescriptionTextView.font = [UIFont fontWithName:fontNameRegular size:16.0f];
    
    self.productTitleLabel.font = [UIFont fontWithName:fontNameRegular size:20.0f];
}

- (void)populateDataWithProduct:(VProduct *)product
{
    NSString *localizedFormat = NSLocalizedString( @"PurchaseUnlockWithPrice", nil);
    NSString *unlockTitle = [NSString stringWithFormat:localizedFormat, product.price];
    [self.unlockButton setTitle:unlockTitle forState:UIControlStateNormal];
    
    self.productTitleLabel.text = product.localizedTitle.uppercaseString;
    self.productDescriptionTextView.text = product.localizedDescription;
}

- (void)showError:(NSError *)error withTitle:(NSString *)title
{
    NSString *message = error.localizedDescription;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showRestoringWithMessage:(NSString *)message
{
    self.unlockButton.enabled = NO;
    self.unlockLoadingView.hidden = YES;
    self.restoreButton.hidden = YES;
    self.restoreLoadingView.hidden = NO;
    self.restoreLoadingLabel.text = message;
}

- (void)showUnlockingWithMessage:(NSString *)message
{
    self.restoreButton.enabled = NO;
    self.restoreLoadingView.hidden = YES;
    self.unlockButton.enabled = NO;
    self.unlockButton.backgroundColor = [UIColor grayColor];
    [self.unlockButton setTitle:nil forState:UIControlStateNormal];
    self.unlockLoadingView.hidden = NO;
    self.unlockLoadingLabel.text = message;
}

- (void)resetLoadingState
{
    self.restoreButton.hidden = NO;
    self.restoreButton.enabled = YES;
    self.unlockButton.enabled = YES;
    self.unlockLoadingView.hidden = YES;
    self.restoreLoadingView.hidden = YES;
    self.unlockLoadingLabel.text = nil;
    self.unlockLoadingLabel.text = nil;
    
    [self populateDataWithProduct:self.product];
    self.productImageView.image = self.largeIcon;
    [self.creatorInfoHelper populateViewsWithDependencyManager:self.dependencyManager];
    [self applyTheme];
}

- (void)handlePurchasesRestoredWithProductIdentifiers:(NSSet *)productIdentifiers
{
    NSString *title = [self.stringMaker localizedSuccessTitleWithProductsCount:productIdentifiers.count];
    NSString *message = [self.stringMaker localizedSuccessMessageWithProductsCount:productIdentifiers.count];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action)
                                {
                                    // If the product for which this view controller was instantiated was returned during
                                    // a purchase restore, then we should dismiss since there's no need to buy it anymore
                                    if ( [productIdentifiers containsObject:self.productIdentifier] )
                                    {
                                        [self.delegate purchaseDidFinish:YES];
                                    }
                                }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - IB Actions

- (IBAction)close:(id)sender
{
    NSDictionary *params = @{ VTrackingKeyProductIdentifier : self.productIdentifier ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidCancelPurchase parameters:params];
    
    [self.delegate purchaseDidFinish:NO];
}

- (IBAction)restorePurchasesTapped:(id)sender
{
    [self showRestoringWithMessage:NSLocalizedString( @"ActivityRestoring", nil)];
    [self.purchaseManager restorePurchasesSuccess:^(NSSet *restoreProductIdentifiers)
     {
         [self resetLoadingState];

         [self handlePurchasesRestoredWithProductIdentifiers:restoreProductIdentifiers];
     }
                                                failure:^(NSError *error)
     {
         [self resetLoadingState];
         NSString *title = NSLocalizedString( @"RestorePurchasesErrorTitle", nil );
         [self showError:error withTitle:title];
     }];
}

- (IBAction)buyTapped:(id)sender
{
    if ( self.productIdentifier == nil )
    {
        return;
    }
    
    [self showUnlockingWithMessage:NSLocalizedString( @"ActivityPurchasing", nil)];
    NSString *productIdentifier = self.productIdentifier;
    [self.purchaseManager purchaseProductWithIdentifier:productIdentifier success:^(NSSet *productIdentifiers)
     {
         [self resetLoadingState];
         [self.delegate purchaseDidFinish:YES];
     }
                                  failure:^(NSError *error)
     {
         [self resetLoadingState];
         
         // If error is nil, the user cancelled the purchase
         if ( error != nil )
         {
             NSString *title = NSLocalizedString( @"PurchaseErrorTitle", nil );
             [self showError:error withTitle:title];
         }
     }];
}

@end
