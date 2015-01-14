//
//  VAbstractFilter+RestKit.h
//  victorious
//
//  Created by Will Long on 6/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractFilter.h"

/**
 To handle loading paginated results, many methods will accept a parameter
 of this type to look up a `VAbstractFilter` instance that tracks the state
 of a series of paginated requests.
 */
typedef NS_ENUM( NSUInteger, VPageType )
{
    /**
     Prefiously `isRefresh` or `shouldRefresh`, this indicates a methods should clear
     any previously loaded results and begin loading from page 1
     */
    VPageTypeFirst,
    
    /**
     Indicates that a method should load the next page (+1) based on the `VAbstractFilter`
     instance that is currently encapsulating its state.  Any loaded results should be
     appended to existing results.
     */
    VPageTypeNext,
    
    /**
     Indicates that a method should load the previous page (-1) based on the `VAbstractFilter`
     instance that is currently encapsulating its state.  Any loaded results should be
     prepended to existing results.
     */
    VPageTypePrevious
};

/**
 An object that encapsulates the state of a series of requests that will return paginated
 results.  An instance persists in memory through CoreDAta and is retrieved by its `filterAPIPath`
 property.  This is what tracks the current page in context with the total number of pages
 and allows methods to return a single, specific page of results.
 */
@interface VAbstractFilter (RestKit)

+ (NSString *)entityName;

@end
