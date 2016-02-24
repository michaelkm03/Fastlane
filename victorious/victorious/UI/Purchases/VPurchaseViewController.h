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

@interface VPurchaseViewController : UIViewController <VSimpleModalTransitionPresentedViewController, VHasManagedDependencies>

@property (nonatomic, weak) id<VPurchaseViewControllerDelegate> _Nullable delegate;

@property (nonatomic, strong) UIImage * _Nonnull largeIcon;
@property (nonatomic, strong) NSString * _Nonnull productIdentifier;

/** Exposing public property so that external classes/categories can animate it */
@property (weak, nonatomic) IBOutlet UIView * backgroundScreen;

/** Exposing public property so that external classes/categories can animate it */
@property (weak, nonatomic) IBOutlet UIView *modalContainer;

+ (instancetype)newWithDependencyManager:(VDependencyManager * _Nonnull)dependencyManager
                       productIdentifier:(NSString * _Nonnull)productIdentifier
                               largeIcon:(UIImage * _Nonnull)largeIcon;

+ (instancetype)newWithDependencyManager:(VDependencyManager * _Nonnull)dependencyManager NS_UNAVAILABLE;

@end
