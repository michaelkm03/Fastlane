//
//  VPurchaseManager.m
//  victorious
//
//  Created by Patrick Lynch on 12/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import StoreKit;

#define SHOULD_SIMULATE_ACTIONS ((DEBUG || TARGET_IPHONE_SIMULATOR) && 0)
#define SIMULATION_DELAY 1.0f
#define SIMULATE_PURCHASE_ERROR 1
#define SIMULATE_FETCH_PRODUCTS_ERROR 0
#define SIMULATE_RESTORE_PURCHASE_ERROR 0

#if SHOULD_SIMULATE_ACTIONS
#warning VPurchaseManager is simulating success and/or failures
#endif

#import "VPurchaseManager.h"
#import "VProduct.h"
#import "VPurchase.h"

@interface VPurchaseManager() <SKProductsRequestDelegate, SKPaymentTransactionObserver>

// These are products currently in some state or purchasing
@property (nonatomic, strong) VPurchase *activePurchase;
@property (nonatomic, strong) VProductsRequest *activeProductRequest;
@property (nonatomic, strong) VPurchase *activePurchaseRestore;

@end

@implementation VPurchaseManager

#pragma mark - Public methods

- (void)purchaseProduct:(VProduct *)product success:(VPurchaseSuccessBlock)successCallback failure:(VPurchaseFailBlock)failureCallback
{
    self.activePurchase = [[VPurchase alloc] initWithProduct:product success:successCallback failure:failureCallback];
    
#if SHOULD_SIMULATE_ACTIONS
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SIMULATION_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
#if SIMULATE_PURCHASE_ERROR
        [self transactionDidFailWithErrorCode:SKErrorUnknown productIdentifier:product.storeKitProduct.productIdentifier];
#else
        [self transationDidCompleteWithProductIdentifier:product.storeKitProduct.productIdentifier];
#endif
    });
    return;
#endif
    
    SKPayment *payment = [SKPayment paymentWithProduct:product.storeKitProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restorePurchasesSuccess:(VPurchaseSuccessBlock)successCallback failure:(VPurchaseFailBlock)failureCallback
{
    self.activePurchaseRestore = [[VPurchase alloc] initWithSuccess:successCallback failure:failureCallback];
    
#if SHOULD_SIMULATE_ACTIONS
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SIMULATION_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
#if SIMULATE_RESTORE_PURCHASE_ERROR
        [self transactionDidFailWithErrorCode:error.code productIdentifier:nil];
#else
        self.activePurchaseRestore.successCallback( self.activeProductRequest.products );
        self.activePurchaseRestore = nil;
#endif
    });
    return;
#endif
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)fetchProductsWithIdentifiers:(NSArray *)productIdenfiters
                             success:(VProductsRequestSuccessBlock)successCallback
                             failure:(VProductsRequestFailureBlock)failureCallback
{
    self.activeProductRequest = [[VProductsRequest alloc] initWithProductIdentifiers:productIdenfiters
                                                                             success:successCallback
                                                                             failure:failureCallback];
#if SHOULD_SIMULATE_ACTIONS
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SIMULATION_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
#if SIMULATE_FETCH_PRODUCTS_ERROR
        for ( identifier in productIdenfiters )
        {
            [self.activeProductRequest productIdentifierFailedToFetch:identifier];
        }
#else
        self.activeProductRequest.successCallback( self.activeProductRequest.products );
        self.activeProductRequest = nil;
#endif
    });
return;
#endif

    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIdenfiters]];
    request.delegate = self;
    [request start];
}

#pragma mark - StoreKit Helpers

- (void)transactionDidFailWithErrorCode:(NSInteger)errorCode productIdentifier:(NSString *)productIdentifier
{
    NSString *message = nil;
    switch ( errorCode )
    {
        case SKErrorClientInvalid:
            message = NSLocalizedString( @"Purchase error invalid.", nil);
            break;
        case SKErrorPaymentCancelled:
            message = NSLocalizedString( @"Purchase cancelled.", nil);
            break;
        case SKErrorPaymentInvalid:
        case SKErrorPaymentNotAllowed:
            message = NSLocalizedString( @"Purchase error not allowed.", nil);
            break;
        case SKErrorStoreProductNotAvailable:
            message = NSLocalizedString( @"Purchase error unavailable.", nil);
            break;
        default:
        case SKErrorUnknown:
            message = NSLocalizedString( @"Purchase error unknown.", nil);
            break;
    }
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : message };
    NSError *error = [NSError errorWithDomain:message code:-1 userInfo:userInfo];
    
    if ( productIdentifier == nil )
    {
        self.activePurchaseRestore.failureCallback( error );
        self.activePurchaseRestore = nil;
    }
    else if ( self.activeProductRequest != nil && [self.activeProductRequest.productIdentifiers containsObject:productIdentifier] )
    {
        self.activeProductRequest.failureCallback( error );
        self.activeProductRequest = nil;
    }
    else if ( self.activePurchase != nil && [self.activePurchase.product.storeKitProduct.productIdentifier isEqualToString:productIdentifier] )
    {
        self.activePurchase.failureCallback( error );
        self.activePurchase = nil;
    }
}

- (void)transactionRestoreDidComplete:(SKPaymentTransaction *)transaction
{
    if ( self.activePurchaseRestore != nil )
    {
        self.activePurchaseRestore.successCallback( nil );
        self.activePurchaseRestore = nil;
    }
}

- (void)transactionDidCompleteWithProductIdentifier:(NSString *)productIdentifier
{
    if ( self.activePurchase != nil && [self.activePurchase.product.storeKitProduct.productIdentifier isEqualToString:productIdentifier] )
    {
        self.activePurchase.successCallback( self.activePurchase.product );
        self.activePurchase = nil;
    }
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if ( self.activeProductRequest == nil )
    {
        return;
    }
    
    for ( SKProduct *product in response.products )
    {
        [self.activeProductRequest productFetched:[[VProduct alloc] initWithStoreKitProduct:product]];
    }
    
    for ( NSString *productIdentifier in response.invalidProductIdentifiers)
    {
        [self.activeProductRequest productIdentifierFailedToFetch:productIdentifier];
    }
    
    if ( self.activeProductRequest.isFetchComplete )
    {
        self.activeProductRequest.successCallback( self.activeProductRequest.products );
        self.activeProductRequest = nil;
    }
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for ( SKPaymentTransaction *transaction in transactions )
    {
        switch ( transaction.transactionState )
        {
            case SKPaymentTransactionStatePurchased:
                VLog( @"Purchase of product '%@' completed", transaction.payment.productIdentifier );
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [self transactionDidCompleteWithProductIdentifier:transaction.payment.productIdentifier];
                break;
            case SKPaymentTransactionStateFailed:
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [self transactionDidFailWithErrorCode:transaction.error.code productIdentifier:transaction.payment.productIdentifier];
                break;
                
            case SKPaymentTransactionStateRestored:
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [self transactionRestoreDidComplete:transaction];
                break;
                
            case SKPaymentTransactionStatePurchasing:
                break;
                
            default:
                break;
        }
    }
}

// Sent when transactions are removed from the queue (via finishTransaction:).
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    for ( SKPaymentTransaction *transaction in transactions )
    {
        switch ( transaction.transactionState )
        {
            case SKPaymentTransactionStatePurchased:
                VLog( @"Purchase of product '%@' completed", transaction.payment.productIdentifier );
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateRestored:
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
                
            case SKPaymentTransactionStatePurchasing:
                break;
                
            default:
                break;
        }
    }
}

// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    [self transactionDidFailWithErrorCode:error.code productIdentifier:nil];
}

@end
