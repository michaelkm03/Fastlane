//
//  VAbstractFilter+RestKit.m
//  victorious
//
//  Created by Will Long on 6/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractFilter+RestKit.h"

@implementation VAbstractFilter (RestKit)

+ (NSString *)entityName
{
    return @"AbstractFilter";
}

- (BOOL)isLastPage
{
    return self.currentPageNumber.integerValue == self.maxPageNumber.integerValue;
}

- (BOOL)canLoadPageType:(VPageType)pageType
{
    if ( pageType == VPageTypeFirst )
    {
        return YES; // it should always be possible to load the first page!
    }
    
    // Validate page number (they are NOT zero-indexed)
    NSUInteger pageNumber = [self pageNumberForPageType:pageType];
    return pageNumber > 0 && pageNumber <= self.maxPageNumber.unsignedIntegerValue;
}

- (NSUInteger)pageNumberForPageType:(VPageType)pageType
{
    switch ( pageType )
    {
        case VPageTypeNext:
            return self.currentPageNumber.integerValue + 1;
            
        case VPageTypePrevious:
            return MAX( self.currentPageNumber.integerValue, 1 ) - 1;
            
        case VPageTypeFirst:
        default:
            return 1;
    }
}

@end
