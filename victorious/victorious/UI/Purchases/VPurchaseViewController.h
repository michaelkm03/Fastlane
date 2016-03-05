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

NS_ASSUME_NONNULL_BEGIN

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

@property (nonatomic, strong) UIImage * largeIcon;
@property (nonatomic, strong) NSString *productIdentifier;

/** Exposing public property so that external classes/categories can animate it */
@property (weak, nonatomic, null_unspecified) IBOutlet UIView *backgroundScreen;

/** Exposing public property so that external classes/categories can animate it */
@property (weak, nonatomic, null_unspecified) IBOutlet UIView *modalContainer;

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
                       productIdentifier:(NSString *)productIdentifier
                               largeIcon:(UIImage *)largeIcon;

+ (instancetype)newWithDependencyManager:(VDependencyManager * _Nonnull)dependencyManager NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
