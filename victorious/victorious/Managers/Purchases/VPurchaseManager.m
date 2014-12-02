//
//  VPurchaseManager.m
//  victorious
//
//  Created by Patrick Lynch on 12/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import StoreKit;

#if TARGET_IPHONE_SIMULATOR
#define SIMULATE_ERROR 1
#define SIMULATE_COMPLETION 0
#define SIMULATE_ALREADY_PURCHASED 0
#define SIMULATE_CANCELLED 0
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
    
#if SIMULATE_COMPLETION
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), successBlock );
#elsif SIMULATE_ERROR
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSError *error = [NSError errorWithDomain:@"" code:-1 userInfo:userInfo];
        failureCallback( error );
    });
#endif
    
#if TARGET_IPHONE_SIMULATOR
    return;
#endif
    
    SKPayment *payment = [SKPayment paymentWithProduct:product.storeKitProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restorePurchasesSuccess:(VPurchaseSuccessBlock)successCallback failure:(VPurchaseFailBlock)failureCallback
{
    self.activePurchaseRestore = [[VPurchase alloc] initWithSuccess:successCallback failure:failureCallback];
    
#if TARGET_IPHONE_SIMULATOR
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), successBlock );
    return;
#endif
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)fetchProductsWithIdentifiers:(NSArray *)productIdenfiters
                             success:(VProductsRequestSuccessBlock)successCallback
                             failure:(VProductsRequestFailureBlock)failureCallback
{
#if TARGET_IPHONE_SIMULATOR
    return;
#endif
    
    self.activeProductRequest = [[VProductsRequest alloc] initWithProductIdentifiers:productIdenfiters
                                                                             success:successCallback
                                                                             failure:failureCallback];
    
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIdenfiters]];
    request.delegate = self;
    [request start];
}

#pragma mark - StoreKit Helpers

- (void)transactionDidError:(SKPaymentTransaction *)transaction
{
    if ( transaction.error == nil )
    {
        VLog( @"Uknown transaction error." );
        return;
    }
    
    NSString *message = nil;
    switch ( transaction.error.code )
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
    
    NSString *productIdentifier = transaction.payment.productIdentifier;
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

- (void)transactionDidComplete:(SKPaymentTransaction *)transaction
{
    if ( transaction == nil || transaction.payment == nil )
    {
        return;
    }
    
    if ( self.activePurchase != nil )
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
    
    for( NSString *productIdentifier in response.invalidProductIdentifiers)
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
                [self transactionDidComplete:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [self transactionDidError:transaction];
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
    switch ( error.code )
    {
        case SKErrorPaymentCancelled:
            break;
            
        default:
            break;
    }
}

@end
