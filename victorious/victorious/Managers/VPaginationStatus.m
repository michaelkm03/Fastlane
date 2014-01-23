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
        self.pagesLoaded = 0;
        self.totalPages = 1;
        self.itemsPerPage = 20;
    }
    return self;
}

- (BOOL)isFullyLoaded
{
    return self.pagesLoaded >= self.totalPages;
}

@end
