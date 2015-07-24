//
//  VMediaTypeHelper.h
//  victorious
//
//  Created by Sharif Ahmed on 7/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VMediaType.h"

#warning NEEDS TESTS

@class VAsset;

/**
    A helper for finding the appropriate media type for a category string or asset.
 */
@interface VMediaTypeHelper : NSObject

/**
    Returns the appropriate media type for the provided asset and media category.
 
    @param asset An asset representing a piece of media.
    @param mediaCategory The category or media type string for the managed object
                            whose nodes contain this asset.
 
    @return The appropriate media type for the provided asset and media category
 */
+ (VMediaType)linkTypeForAsset:(VAsset *)asset andMediaCategory:(NSString *)mediaCategory;

@end
