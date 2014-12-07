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
#import "VFileCache.h"
#import "VFileCache+VVoteType.h"

@interface VPurchaseViewController ()

@property (strong, nonatomic) VPurchaseManager *purchaseManager;
@property (strong, nonatomic) VProduct *product;

@property (weak, nonatomic) IBOutlet UILabel *productTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *creatorSalutationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *creatorAvatarImageView;
@property (weak, nonatomic) IBOutlet UITextView *productDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UIView *unlockLoadingView;
@property (weak, nonatomic) IBOutlet UILabel *unlockLoadingLabel;
@property (weak, nonatomic) IBOutlet UIView *restoreLoadingView;
@property (weak, nonatomic) IBOutlet UILabel *restoreLoadingLabel;
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
    
    self.creatorAvatarImageView.layer.cornerRadius = 17.0f; // Enough to make it a circle
    self.creatorAvatarImageView.layer.borderWidth = 1.0f;
    self.creatorAvatarImageView.layer.masksToBounds = YES;
    
    [self resetLoadingState];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Helpers

- (void)applyTheme
{
    UIColor *linkColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    
    NSString *fontNameRegular = @"MuseoSans-300";
    NSString *fontNameBold = @"MuseoSans-500";
    
    self.unlockButton.backgroundColor = linkColor;
    self.unlockButton.titleLabel.font = [UIFont fontWithName:fontNameRegular size:18.0f];
    
    self.unlockButton.style = VButtonStylePrimary;
    
    self.restoreButton.titleLabel.font = [UIFont fontWithName:fontNameRegular size:15.0f];
    self.restoreButton.style = VButtonStyleSecondary;
    
    self.productDescriptionTextView.font = [UIFont fontWithName:fontNameRegular size:17.0f];
    
    self.productTitleLabel.font = [UIFont fontWithName:fontNameRegular size:20.0f];
    
    self.creatorSalutationLabel.font = [UIFont fontWithName:fontNameBold size:11.0f];
    
    self.creatorAvatarImageView.layer.borderColor = linkColor.CGColor;
}

- (void)populateDataFromBundle
{
    NSBundle *bundle = [NSBundle mainBundle];
    
    NSString *salutation = [bundle objectForInfoDictionaryKey:@"CreatorSalutation"];
    self.creatorSalutationLabel.text = [NSString stringWithFormat:@"–%@", salutation];
    self.creatorAvatarImageView.image = [UIImage imageNamed:@"creator-avatar"];
}

- (void)populateDataWithVoteType:(VVoteType *)voteType
{
    VFileCache *fileCache = [[VFileCache alloc] init];
    self.productImageView.image = [fileCache getImageWithName:VVoteTypeIconLargeName forVoteType:self.voteType];
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
    VAlertController *alertConroller = [VAlertController alertWithTitle:title message:message];
    [alertConroller addAction:[VAlertAction cancelButtonWithTitle:NSLocalizedString( @"OKButton", nil ) handler:nil]];
    [alertConroller presentInViewController:self animated:YES completion:nil];
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
    self.restoreButton.enabled = YES;
    self.unlockButton.enabled = YES;
    self.unlockLoadingView.hidden = YES;
    self.restoreLoadingView.hidden = YES;
    self.unlockLoadingLabel.text = nil;
    self.unlockLoadingLabel.text = nil;
    
    [self populateDataWithProduct:self.product];
    [self populateDataWithVoteType:self.voteType];
    [self populateDataFromBundle];
    [self applyTheme];
}

#pragma mark - IB Actions

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)restorePurchasesTapped:(id)sender
{
    [self showRestoringWithMessage:NSLocalizedString( @"ActivityRestoring", nil)];
    [self.purchaseManager restorePurchasesSuccess:^(NSArray *productIdentifiers)
     {
         [[VSettingManager sharedManager].voteSettings didCompletePurchaseWithProductIdentifiers:productIdentifiers];
         
         [self resetLoadingState];
         [self dismissViewControllerAnimated:YES completion:nil];
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
    if ( self.voteType == nil )
    {
        return;
    }
    
    [self showUnlockingWithMessage:NSLocalizedString( @"ActivityPurchasing", nil)];
    NSString *productIdentifier = self.voteType.productIdentifier;
    [self.purchaseManager purchaseProductWithIdentifier:productIdentifier success:^(NSArray *productIdentifiers)
     {
         [[VSettingManager sharedManager].voteSettings didCompletePurchaseWithProductIdentifiers:@[ productIdentifier ]];
         
         [self resetLoadingState];
         [self dismissViewControllerAnimated:YES completion:nil];
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
