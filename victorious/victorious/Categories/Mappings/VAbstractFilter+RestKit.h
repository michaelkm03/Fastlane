//
//  VAbstractFilter+RestKit.h
//  victorious
//
//  Created by Will Long on 6/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractFilter.h"
#import "VPageType.h"

/**
 An object that encapsulates the state of a series of requests that will return paginated
 results.  An instance persists in memory through CoreData and is retrieved by its `filterAPIPath`
 property.  This is what tracks the current page in context with the total number of pages
 and allows methods to return specific single page of results.
 */
@interface VAbstractFilter (RestKit)

+ (NSString *)entityName;

/**
 Checks if the page type can be loaded, i.e. a page exists for the type of page supplied.
 */
- (BOOL)canLoadPageType:(VPageType)pageType;

/**
 Uses pageType provided to calculate related page number.
 */
- (NSUInteger)pageNumberForPageType:(VPageType)pageType;

@property(nonatomic, readonly) BOOL isLastPage;

@end
