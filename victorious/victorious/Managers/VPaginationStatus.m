//
//  VPaginationStatus.m
//  victoriOS
//
//  Created by Will Long on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VPaginationStatus.h"

@implementation VPaginationStatus

- (id)init
{
    self = [super init];
    if (self)
    {
        _pagesLoaded = 0;
        _totalPages = 1;
        _itemsPerPage = 10;
    }
    return self;
}

- (BOOL)isFullyLoaded
{
    return _pagesLoaded >= _totalPages;
}

@end
