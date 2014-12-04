//
//  VPurchaseManager.m
//  victorious
//
//  Created by Patrick Lynch on 12/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import StoreKit;

#define SHOULD_SIMULATE_ACTIONS TARGET_IPHONE_SIMULATOR || (DEBUG && 1)
#define SIMULATION_DELAY 1.0f
#define SIMULATE_PURCHASE_ERROR 0
#define SIMULATE_FETCH_PRODUCTS_ERROR 0
#define SIMULATE_RESTORE_PURCHASE_ERROR 0

#if SHOULD_SIMULATE_ACTIONS
#warning VPurchaseManager is simulating success and/or failures
#endif

#import "VPurchaseManager.h"
#import "VPurchase.h"
#import "VPurchaseManagerCache.h"

@interface VPurchaseManager() <SKProductsRequestDelegate, SKPaymentTransactionObserver>

// These are products currently in some state or purchasing
@property (nonatomic, strong) VPurchase *activePurchase;
@property (nonatomic, strong) VProductsRequest *activeProductRequest;
@property (nonatomic, strong) VPurchase *activePurchaseRestore;

@end

@implementation VPurchaseManager

+ (VPurchaseManagerCache *)sharedCache
{
    static VPurchaseManagerCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      cache = [[VPurchaseManagerCache alloc] init];
                  });
    return cache;
}

#pragma mark - Public methods

- (NSArray *)purchasedProducts
{
    return nil;
}

- (NSArray *)purchaseableProducts
{
    
    return nil;
}

- (void)purchaseProduct:(VProduct *)product success:(VPurchaseSuccessBlock)successCallback failure:(VPurchaseFailBlock)failureCallback
{
    self.activePurchase = [[VPurchase alloc] initWithProduct:product success:successCallback failure:failureCallback];
    
#if SHOULD_SIMULATE_ACTIONS
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SIMULATION_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        NSString *productIdentifier = @"test";
#if SIMULATE_PURCHASE_ERROR
        [self transactionDidFailWithErrorCode:SKErrorUnknown productIdentifier:productIdentifier];
#else
        [self transactionDidCompleteWithProductIdentifier:productIdentifier];
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SIMULATION_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
#if SIMULATE_RESTORE_PURCHASE_ERROR
        [self transactionDidFailWithErrorCode:error.code productIdentifier:nil];
#else
        [self transactionDidCompleteWithProductIdentifier:nil];
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
    if ( productIdenfiters == nil || productIdenfiters.count == 0 )
    {
        if ( successCallback != nil )
        {
            successCallback( self.purchaseableProducts );
        }
        return;
    }
    
    NSArray *uncachedProductIndentifiers = [self productIdentifiersFilteredForUncachedProducts:productIdenfiters];
    self.activeProductRequest = [[VProductsRequest alloc] initWithProductIdentifiers:uncachedProductIndentifiers
                                                                             success:successCallback
                                                                             failure:failureCallback];
#if SHOULD_SIMULATE_ACTIONS
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SIMULATION_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        NSArray *testIdentifiers = @[ @"test1", @"test2", @"test3" ];
#if SIMULATE_FETCH_PRODUCTS_ERROR
        for ( NSString *identifier in testIdentifiers )
        {
            [self.activeProductRequest productIdentifierFailedToFetch:identifier];
        }
        [self productsRequestDidFailWithError:[NSError errorWithDomain:@"Failed to fetch products" code:-1 userInfo:nil]];
#else
        for ( __unused NSString *identifier in testIdentifiers )
        {
            [self.activeProductRequest productFetched:[[VProduct alloc] init]];
        }
        [self productsRequestDidSucceed];
#endif
    });
return;
#endif

    NSSet *productIdentifiersSet = [NSSet setWithArray:uncachedProductIndentifiers];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiersSet];
    request.delegate = self;
    [request start];
}

#pragma mark - StoreKit Helpers

- (NSArray *)productIdentifiersFilteredForUncachedProducts:(NSArray *)productIdentifiers
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL( NSString* identifier, NSDictionary *bindings)
    {
        return [[[[self class] sharedCache] purchaseableProducts] valueForKey:identifier] != nil;
    }];
    return [productIdentifiers filteredArrayUsingPredicate:predicate];
}

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
        if ( self.activeProductRequest.failureCallback != nil )
        {
            self.activeProductRequest.failureCallback( error );
        }
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
#if SHOULD_SIMULATE_ACTIONS
    BOOL isValidProduct = YES;
#else
    BOOL isValidProduct = [self.activePurchase.product.storeKitProduct.productIdentifier isEqualToString:productIdentifier];
#endif
    if ( self.activePurchase != nil && isValidProduct )
    {
        [[[[self class] sharedCache] purchasedProducts] setValue:self.activePurchase.product forKey:productIdentifier];
        self.activePurchase.successCallback( @[ self.activePurchase.product ] );
        self.activePurchase = nil;
    }
}

- (void)productsRequestDidSucceed
{
    if ( self.activeProductRequest != nil )
    {
        [self.activeProductRequest.products enumerateObjectsUsingBlock:^(VProduct *product, NSUInteger idx, BOOL *stop)
         {
             [[[[self class] sharedCache] purchaseableProducts] setValue:product forKey:product.storeKitProduct.productIdentifier];
         }];
        self.activeProductRequest.successCallback( self.purchaseableProducts );
    }
    self.activeProductRequest = nil;
}

- (void)productsRequestDidFailWithError:(NSError *)error
{
    self.activeProductRequest.failureCallback( error );
    self.activeProductRequest = nil;
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
        [self productsRequestDidSucceed];
    }
    else
    {
        NSString *message = NSLocalizedString( @"Purchase error unknown.", nil);
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : message };
        NSError *error = [NSError errorWithDomain:message code:-1 userInfo:userInfo];
        [self productsRequestDidFailWithError:error];
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
