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

@interface VPurchaseViewController ()

@property (nonatomic, strong) VPurchaseManager *purchaseManager;

@end

@implementation VPurchaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.purchaseManager = [[VPurchaseManager alloc] init];
    
    NSString *title = NSLocalizedString( @"Buy This Emotive Ballstic", nil);
    [self v_addNewNavHeaderWithTitles:@[ title ]];
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
    
    VProduct *product = [self.purchaseManager purcahseableProductForIdenfitier:productIdentifier];
    [self.purchaseManager purchaseProduct:product success:^(NSArray *products)
     {
         
     }
                                  failure:^(NSError *error)
     {
         
     }];
}

@end
