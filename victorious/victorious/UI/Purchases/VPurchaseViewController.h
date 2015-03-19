//
//  VPurchaseViewController.h
//  victorious
//
//  Created by Patrick Lynch on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VVoteType.h"
#import "VSimpleModalTransition.h"

@class VDependencyManager;

@protocol VPurchaseViewControllerDelegate <NSObject>

/**
 Called when the purchase view controller should be dismissed.
 @param didMakePurchase Whether a product has been successfuly purchased or restored.
 If NO, the user exited the purchase view without making a purchase.
 */
- (void)purchaseDidFinish:(BOOL)didMakePurchase;

@end

@interface VPurchaseViewController : UIViewController <VSimpleModalTransitionPresentedViewController, VHasManagedDependancies>

@property (nonatomic, strong) id<VPurchaseViewControllerDelegate> delegate;

/**
 The vote type that a user is trying to unlock.  This is where the product identifier
 used to make purchases in the App Store comes from.  This property should be set immediately after
 initialization.  The convenience initializer instantiateFromStoryboard:withVoteType will handle
 setting this using the supplied vote type parameter.
 */
@property (nonatomic, strong) VVoteType *voteType;

/** Exposing public property so that external classes/categories can animate it */
@property (weak, nonatomic) IBOutlet UIView *backgroundScreen;

/** Exposing public property so that external classes/categories can animate it */
@property (weak, nonatomic) IBOutlet UIView *modalContainer;

@end
