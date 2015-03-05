//
//  VPaginationManager.h
//  victorious
//
//  Created by Josh Hinman on 8/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VObjectManager.h"
#import "VAbstractFilter+RestKit.h"

extern NSString * const VPaginationManagerPageNumberMacro; ///< A macro that, if it appears in the filter path, will be replaced by the page number
extern NSString * const VPaginationManagerItemsPerPageMacro; ///< A macro that, if it appears in the filter path, will be replaced by the number of items per page

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
 Returns YES if the set of data in the given filter is
 currently being loaded.
 */
- (BOOL)isLoadingFilter:(VAbstractFilter *)filter;

/**
 Returns a filter to keep track of the metadata for a set of paged data, e.g. the current page and total pages available.
 If no filter exists, it will be created and stored in the object manager.
 */
- (VAbstractFilter *)filterForPath:(NSString *)path
                        entityName:(NSString *)entityName
              managedObjectContext:(NSManagedObjectContext *)context;

/**
 Use a filter and page type to load a paginated request.
 */
- (RKManagedObjectRequestOperation *)loadFilter:(VAbstractFilter *)filter
                                   withPageType:(VPageType)pageType
                                   successBlock:(VSuccessBlock)success
                                      failBlock:(VFailBlock)fail;

@end
