//
//  VProductsRequest.h
//  victorious
//
//  Created by Patrick Lynch on 12/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VProduct;

typedef void (^VProductsRequestFailureBlock) (NSError *error);
typedef void (^VProductsRequestSuccessBlock) (NSArray *products);

@interface VProductsRequest : NSObject

- (instancetype)initWithProductIdentifiers:(NSArray *)productIdenfiters
                                   success:(VProductsRequestSuccessBlock)successCallback
                                   failure:(VProductsRequestFailureBlock)failureCallback;

- (void)productFetched:(VProduct *)product;

- (void)productIdentifierFailedToFetch:(NSString *)productIdentifier;

@property (nonatomic, readonly) NSArray *productIdentifiers;
@property (nonatomic, readonly) VProductsRequestFailureBlock failureCallback;
@property (nonatomic, readonly) VProductsRequestSuccessBlock successCallback;
@property (nonatomic, readonly, assign) BOOL isFetchComplete;
@property (nonatomic, strong) NSMutableArray *products;

@end
