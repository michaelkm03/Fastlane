//
//  VPurchaseRecord.h
//  victorious
//
//  Created by Patrick Lynch on 12/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPurchaseRecord : NSObject

/**
 Initialize with a filepath used for writing and reading the purchased record data to disk.
 */
- (instancetype)initWithRelativeFilePath:(NSString *)filepath;

/**
 Adds the product identifier to the local purchase record and writes to disk.  Call this
 immeidately after the product has been purchased or has been restored so that it will be
 available after restarting the app.
 */
- (void)addProductIdentifier:(NSString *)productIdentifier;

/**
 Read the purchase record from disk into memory.
 */
- (NSArray *)loadPurchasedProductIdentifiers;

/**
 All of the currently purchased product identifiers.  All other methods of this class
 will automatically read and write when necessary to keep this property up to date.
 */
@property (nonatomic, readonly) NSArray *purchasedProductIdentifiers;

@end
