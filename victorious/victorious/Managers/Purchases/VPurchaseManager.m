//
//  VPurchaseManager.m
//  victorious
//
//  Created by Patrick Lynch on 12/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import StoreKit;

#define SHOULD_SIMULATE_ACTIONS TARGET_IPHONE_SIMULATOR || (DEBUG && 0)
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
@property (nonatomic, strong) VPurchaseManagerCache *cache;

@end

@implementation VPurchaseManager

#pragma mark - Initialization

+ (VPurchaseManager *)sharedInstance
{
    static VPurchaseManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      instance = [[VPurchaseManager alloc] init];
                  });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.cache = [[VPurchaseManagerCache alloc] init];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

#pragma mark - Public methods
- (void)purchaseProductWithIdentifier:(NSString *)productIdentifier success:(VPurchaseSuccessBlock)successCallback failure:(VPurchaseFailBlock)failureCallback
{
    VProduct *product = [self purcahseableProductForIdenfitier:productIdentifier];
    [self purchaseProduct:product success:successCallback failure:failureCallback];
}

- (void)purchaseProduct:(VProduct *)product success:(VPurchaseSuccessBlock)successCallback failure:(VPurchaseFailBlock)failureCallback
{
    if ( product == nil )
    {
        NSString *message = NSLocalizedString( @"Invalid product.", nil);
        failureCallback( [NSError errorWithDomain:message code:-1 userInfo:@{ NSLocalizedDescriptionKey : message }] );
        return;
    }
    
#if SHOULD_SIMULATE_ACTIONS
    self.activePurchase = [[VPurchase alloc] initWithProduct:[[VProduct alloc] init] success:successCallback failure:failureCallback];
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
    
    self.activePurchase = [[VPurchase alloc] initWithProduct:product success:successCallback failure:failureCallback];
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
    if ( self.activeProductRequest != nil )
    {
        // Do not allow two product requests to occur
        return;
    }
    
    NSArray *uncachedProductIndentifiers = [self productIdentifiersFilteredForUncachedProducts:productIdenfiters];
    if ( uncachedProductIndentifiers == nil || uncachedProductIndentifiers.count == 0 )
    {
        if ( successCallback != nil )
        {
            NSArray *products = nil; //[self.cache purchaseableProducts]
            successCallback( products );
        }
        return;
    }
    
    self.activeProductRequest = [[VProductsRequest alloc] initWithProductIdentifiers:uncachedProductIndentifiers
                                                                             success:successCallback
                                                                             failure:failureCallback];
#if SHOULD_SIMULATE_ACTIONS
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SIMULATION_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
#if SIMULATE_FETCH_PRODUCTS_ERROR
        for ( NSString *identifier in uncachedProductIndentifiers )
        {
            [self.activeProductRequest productIdentifierFailedToFetch:identifier];
        }
        [self productsRequestDidFailWithError:[NSError errorWithDomain:@"Failed to fetch products" code:-1 userInfo:nil]];
#else
        for ( __unused NSString *identifier in uncachedProductIndentifiers )
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

- (VProduct *)purcahseableProductForIdenfitier:(NSString *)identifier
{
    return [[self.cache purchaseableProducts] objectForKey:identifier];
}

#pragma mark - StoreKit Helpers

- (NSArray *)productIdentifiersFilteredForUncachedProducts:(NSArray *)productIdentifiers
{
    if ( productIdentifiers == nil )
    {
        return nil;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL (NSString *identifier, NSDictionary *bindings)
    {
        BOOL isCached = [[self.cache purchaseableProducts] objectForKey:identifier] != nil;
        return !isCached;
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
        [[self.cache purchasedProducts] setObject:self.activePurchase.product forKey:productIdentifier];
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
#if SHOULD_SIMULATE_ACTIONS
             NSString *productIdentifier = [NSString stringWithFormat:@"test_%lu", (unsigned long)idx];
#else
             NSString *productIdentifier = product.storeKitProduct.productIdentifier;
#endif
             [[self.cache purchaseableProducts] setObject:product forKey:productIdentifier];
         }];
        NSArray *products = [[self.cache purchaseableProducts] objectsForKeys:self.activeProductRequest.productIdentifiers];
        if ( self.activeProductRequest.successCallback != nil )
        {
            self.activeProductRequest.successCallback( products );
        }
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
