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
 of this type to load subsequent pages of paginated requests.
 */
typedef NS_ENUM( NSUInteger, VPageType )
{
    VPageTypeNext,
    VPageTypePrevious,
    VPageTypeFirst
};
