//
//  VPurchaseViewController.h
//  victorious
//
//  Created by Patrick Lynch on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VVoteType+Fetcher.h"
#import "VModalTransition.h"

@interface VPurchaseViewController : UIViewController <VModalTransitionPresentedViewController>

+ (VPurchaseViewController *)purchaseViewControllerWithVoteType:(VVoteType *)voteType;

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
