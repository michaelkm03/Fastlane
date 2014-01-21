//
//  VObjectManager.h
//  victoriOS
//
//  Created by Will Long on 11/29/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "RKObjectManager.h"
#import "VConstants.h"

/*! Block that executes when the API succeeds. 
 *  Block is given NSArray of objects RestKit created from response. */
typedef void (^SuccessBlock) (NSArray* resultObjects);

typedef void (^AFSuccessBlock) (AFHTTPRequestOperation*, id);

/*! Block that executes when the API fails.
 * Block is given NSError* that RestKit returned. */
typedef void (^FailBlock) (NSError* error);

/*! Block that executes when the API fails.
 * Block is given NSError* that RestKit returned. */
typedef void (^AFFailBlock) (AFHTTPRequestOperation*, NSError*);

/*! Block that will be given Pagination information from API Response.
 *  Block is given NSUInteger for page and NSUInteger for totalPages
 *  NOTE: VObjectManager does not keep track of Pagination Logic.*/
typedef void (^PaginationBlock) (NSUInteger page_number, NSUInteger page_total);


typedef float (^MyBlockType)(float, float);

@class VUser;
@class VSequence;

@interface VObjectManager : RKObjectManager

/*! Sets up [VObjectManager sharedManager] and declares RK entities and descriptors
 */
+ (void)setupObjectManager;

@property (nonatomic, strong) VUser*  mainUser;

@end

