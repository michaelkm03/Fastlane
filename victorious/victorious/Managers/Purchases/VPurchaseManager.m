//
//  VPurchaseManager.m
//  victorious
//
//  Created by Patrick Lynch on 12/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//
@import StoreKit;

#import "VPseudoProduct.h"
#import "VPurchaseManager.h"
#import "VPurchase.h"
#import "VPurchaseRecord.h"
#import "victorious-Swift.h"

NSString * const VPurchaseManagerProductsDidUpdateNotification = @"VPurchaseManagerProductsDidUpdateNotification";

static NSString * const kDocumentDirectoryRelativePath = @"com.getvictorious.devicelog"; // A touch of obscurity

@interface VPurchaseManager() <SKProductsRequestDelegate, SKPaymentTransactionObserver, SKRequestDelegate>

@property (nonatomic, strong) VPurchase *activePurchase;
@property (nonatomic, strong) VProductsRequest *activeProductRequest;
@property (nonatomic, strong) VPurchase *activePurchaseRestore;
@property (nonatomic, strong, readwrite) VPurchaseRecord *purchaseRecord;
@property (nonatomic, strong) NSMutableDictionary *fetchedProducts;

@end

@implementation VPurchaseManager

#pragma mark - Initialization

+ (id<VPurchaseManagerType>)sharedInstance
{
    static VPurchaseManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
#ifdef V_FAKE_PURCHASES
                      instance = [[SimulatedPurchaseManager alloc] init];
#else
                      instance = [[VPurchaseManager alloc] init];
#endif
                  });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.fetchedProducts = [[NSMutableDictionary alloc] init];
        self.purchaseRecord = [[VPurchaseRecord alloc] initWithRelativeFilePath:kDocumentDirectoryRelativePath];
        [self.purchaseRecord loadPurchasedProductIdentifiers];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

#pragma mark - Primary public methods

- (BOOL)isPurchaseRequestActive
{
    return self.activeProductRequest != nil || self.activePurchase != nil || self.activePurchaseRestore != nil;
}

- (NSArray *)purchasedProductIdentifiers
{
    return self.purchaseRecord.purchasedProductIdentifiers;
}

- (BOOL)isProductIdentifierPurchased:(NSString *)productIdentifier
{
    return [self.purchaseRecord.purchasedProductIdentifiers containsObject:productIdentifier];;
}

- (VPurchaseType)purchaseTypeForProductIdentifier:(NSString *)productIdentifier
{
    return VPurchaseTypeSubscription;
}

- (BOOL)shouldAddProductIdentifierToPurchaseRecord:(NSString *)productIdentifier
{
    // Products of type `VPurchaseTypeSubscription` are not stored on the local purchase record
    // but instead are tracked by the backend and readable from the `VUser`.
    return [self purchaseTypeForProductIdentifier:productIdentifier] != VPurchaseTypeSubscription;
}

- (void)purchaseProductWithIdentifier:(NSString *)productIdentifier success:(VPurchaseSuccessBlock)successCallback failure:(VPurchaseFailBlock)failureCallback
{
    VProduct *product = [self purchaseableProductForProductIdentifier:productIdentifier];
    [self purchaseProduct:product success:successCallback failure:failureCallback];
}

- (void)purchaseProduct:(VProduct *)product success:(VPurchaseSuccessBlock)successCallback failure:(VPurchaseFailBlock)failureCallback
{
    NSParameterAssert( failureCallback != nil );
    NSParameterAssert( successCallback != nil );
    NSAssert( !self.isPurchaseRequestActive, @"A purchase is already in progress." );
    
    // This could happen if product requests are failing
    if ( product == nil )
    {
        NSString *message = NSLocalizedString( @"PurchaseErrorProductNotAvailable", nil);
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : message };
        failureCallback( [NSError errorWithDomain:@"" code:-1 userInfo:userInfo] );
        return;
    }
    
    self.activePurchase = [[VPurchase alloc] initWithProduct:product success:successCallback failure:failureCallback];
    SKPayment *payment = [SKPayment paymentWithProduct:product.storeKitProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restorePurchasesSuccess:(VPurchaseSuccessBlock)successCallback failure:(VPurchaseFailBlock)failureCallback
{
    NSAssert( !self.isPurchaseRequestActive, @"A purchase restore is already in progress." );
    self.activePurchaseRestore = [[VPurchase alloc] initWithSuccess:successCallback failure:failureCallback];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)fetchProductsWithIdentifiers:(NSSet *)productIdentifiers
                             success:(VProductsRequestSuccessBlock)successCallback
                             failure:(VProductsRequestFailureBlock)failureCallback
{
    NSAssert( !self.isPurchaseRequestActive, @"A products fetch is already in progress." );
    
    NSSet *uncachedProductIndentifiers = [self productIdentifiersFilteredForUncachedProducts:productIdentifiers];
    if ( uncachedProductIndentifiers == nil || uncachedProductIndentifiers.count == 0 )
    {
        if ( successCallback != nil )
        {
            successCallback( [NSSet setWithArray:[self.fetchedProducts allValues]] );
        }
        return;
    }
    
    self.activeProductRequest = [[VProductsRequest alloc] initWithProductIdentifiers:uncachedProductIndentifiers
                                                                             success:successCallback
                                                                             failure:failureCallback];
    
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    request.delegate = self;
    [request start];
}

- (void)resetPurchases
{
#ifdef V_RESET_PURCHASES
    [self.purchaseRecord clear];
#endif
}

- (VProduct *)purchaseableProductForProductIdentifier:(NSString *)productIdentifier
{
    return [self.fetchedProducts objectForKey:productIdentifier];
}

#pragma mark - Purchase product helpers

- (NSSet *)productIdentifiersFilteredForUncachedProducts:(NSSet *)productIdentifiers
{
    if ( productIdentifiers == nil )
    {
        return nil;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL (NSString *identifier, NSDictionary *bindings)
    {
        BOOL isCached = [self.fetchedProducts objectForKey:identifier] != nil;
        return !isCached;
    }];
    return [productIdentifiers filteredSetUsingPredicate:predicate];
}

- (void)transactionDidFailWithErrorCode:(NSInteger)errorCode productIdentifier:(NSString *)productIdentifier
{
    NSString *message = nil;
    switch ( errorCode )
    {
        case SKErrorPaymentCancelled:
            message = nil;
            break;
        case SKErrorStoreProductNotAvailable:
            message = NSLocalizedString( @"PurchaseErrorProductNotAvailable", nil);
            break;
        default:
            message = NSLocalizedString( @"PurchaseErrorTransaction", nil);
            break;
    }
    
    NSError *error = nil;
    if ( message != nil )
    {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : message };
        error = [NSError errorWithDomain:message code:errorCode userInfo:userInfo];
    }
    
    if ( self.activeProductRequest != nil )
    {
        NSDictionary *params = @{ VTrackingKeyProductIdentifier : productIdentifier ?: @"",
                                  VTrackingKeyErrorMessage : error.localizedDescription ?: @""};
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventAppStoreProductRequestDidFail parameters:params];
        
        if ( self.activeProductRequest.failureCallback != nil )
        {
            self.activeProductRequest.failureCallback( error );
        }
        self.activeProductRequest = nil;
    }
    else if ( self.activePurchase != nil )
    {
        NSDictionary *params = @{ VTrackingKeyProductIdentifier : productIdentifier ?: @"",
                                  VTrackingKeyErrorMessage : error.localizedDescription ?: @""};
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventPurchaseDidFail parameters:params];
        
        self.activePurchase.failureCallback( error );
        self.activePurchase = nil;
    }
}

- (void)transactionDidCompleteWithProductIdentifier:(NSString *)productIdentifier
{
    BOOL isValidProduct = [self.activePurchase.product.storeKitProduct.productIdentifier isEqualToString:productIdentifier];
    if ( self.activePurchase != nil && isValidProduct )
    {
        NSDictionary *params = @{ VTrackingKeyProductIdentifier : productIdentifier ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidCompletePurchase parameters:params];
        
        if ( [self shouldAddProductIdentifierToPurchaseRecord:productIdentifier] )
        {
            [self.purchaseRecord addProductIdentifier:productIdentifier];
        }
        self.activePurchase.successCallback( [NSSet setWithObject:self.activePurchase.product] );
        self.activePurchase = nil;
    }
}

#pragma mark - Products request helpers

- (void)productsRequestDidSucceed
{
    if ( self.activeProductRequest != nil )
    {
        [self.activeProductRequest.products enumerateObjectsUsingBlock:^(VProduct *product, NSUInteger idx, BOOL *stop)
         {
             NSString *productIdentifier = product.storeKitProduct.productIdentifier;
             [self.fetchedProducts setValue:product forKey:productIdentifier];
         }];
        if ( self.activeProductRequest.successCallback != nil )
        {
            self.activeProductRequest.successCallback( [NSSet setWithArray:[self.fetchedProducts allValues]] );
        }
    }
    self.activeProductRequest = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VPurchaseManagerProductsDidUpdateNotification object:nil];
}

- (void)productsRequestDidFailWithError:(NSError *)error
{
    if ( error == nil )
    {
        NSString *message = NSLocalizedString( @"ProductsRequestError", nil);
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : message };
        error = [NSError errorWithDomain:@"" code:-1 userInfo:userInfo];
    }
    
    if ( self.activeProductRequest.failureCallback != nil )
    {
        self.activeProductRequest.failureCallback( error );
    }
    self.activeProductRequest = nil;
}

#pragma mark - Restore purchases helpers

- (void)restorePurchaseTransactionDidCompleteWithProductIdentifier:(NSString *)productIdentifier
{
    if ( self.activePurchaseRestore != nil )
    {
        [self.activePurchaseRestore.restoredProductIdentifiers addObject:productIdentifier];
    }
}

- (void)purchasesDidRestore
{
    if ( self.activePurchaseRestore != nil )
    {
        [self.activePurchaseRestore.restoredProductIdentifiers enumerateObjectsUsingBlock:^(NSString *identifier, BOOL *stop)
         {
             if ( [self shouldAddProductIdentifierToPurchaseRecord:identifier] )
             {
                 [self.purchaseRecord addProductIdentifier:identifier];
             }
        }];
        
        NSDictionary *params = @{ VTrackingKeyCount : @(self.activePurchaseRestore.restoredProductIdentifiers.count) };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidRestorePurchases parameters:params];
        
        self.activePurchaseRestore.successCallback( self.activePurchaseRestore.restoredProductIdentifiers );
        self.activePurchaseRestore = nil;
    }
}

- (void)purchasesDidFailToRestoreWithError:(NSError *)error
{
    NSDictionary *params = @{ VTrackingKeyErrorMessage : error.localizedDescription ?: @""};
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventRestorePurchasesDidFail parameters:params];
    
    NSString *message = NSLocalizedString( @"RestorePurchasesError", nil);
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : message };
    NSError *userFacingError = [NSError errorWithDomain:message code:error.code userInfo:userInfo];
    self.activePurchaseRestore.failureCallback( userFacingError );
    self.activePurchaseRestore = nil;
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
        [self productsRequestDidFailWithError:nil];
    }
}

#pragma mark - SKRequestDelegate

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    [self productsRequestDidFailWithError:error];
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
                [self restorePurchaseTransactionDidCompleteWithProductIdentifier:transaction.payment.productIdentifier];
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
    [self purchasesDidFailToRestoreWithError:error];
}

// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    [self purchasesDidRestore];
}

@end
