//
//  VPageType.h
//  victorious
//
//  Created by Patrick Lynch on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import Foundation;

/**
 To handle loading paginated results, many methods will accept a parameter
 of this type to load subsequent pages of an `VAbstractFilter` instance that
 tracks the state of a series of paginated requests.
 */
typedef NS_ENUM( NSUInteger, VPageType )
{
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
    VPageTypePrevious,
    
    /**
     Indicates that an endpoint should reload its first page and clear out and previously
     stored results in favor of the updated incoming data that will supercede it.
     */
    VPageTypeRefresh,
    
    /**
     Indicates that an endpoint should reload its first page but NOT clear out and previously
     stored results.
     */
    VPageTypeCheckNew
};