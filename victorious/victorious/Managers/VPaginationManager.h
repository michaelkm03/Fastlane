//
//  VPaginationManager.h
//  victorious
//
//  Created by Josh Hinman on 8/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"

#import <Foundation/Foundation.h>

@class VAbstractFilter;

/**
 Manages loading data from the server in multiple "pages"
 in a thread-safe way.
 */
@interface VPaginationManager : NSObject

@property (nonatomic, weak, readonly) VObjectManager *objectManager;

/**
 The designated initializer.
 
 @param objectManager the object manager for which we are to manage loading data.
 */
- (instancetype)initWithObjectManager:(VObjectManager *)objectManager;

/**
 Load the first page of a filter, erasing any existing data.
 */
- (RKManagedObjectRequestOperation *)refreshFilter:(VAbstractFilter *)filter
                                      successBlock:(VSuccessBlock)success
                                         failBlock:(VFailBlock)fail;

/**
 Load the next page of data for a filter
 */
- (RKManagedObjectRequestOperation *)loadNextPageOfFilter:(VAbstractFilter*)filter
                                             successBlock:(VSuccessBlock)success
                                                failBlock:(VFailBlock)fail;

/**
 Returns YES if the set of data in the given filter is
 currently being loaded.
 */
- (BOOL)isLoadingFilter:(VAbstractFilter *)filter;

/**
 Returns a filter to keep track of the metadata for a set of paged data, e.g. the current page and total pages available.
 If no filter exists, it will be created and stored in the object manager.
 */
- (VAbstractFilter *)filterForPath:(NSString *)path entityName:(NSString*)entityName managedObjectContext:(NSManagedObjectContext *)context;

@end
