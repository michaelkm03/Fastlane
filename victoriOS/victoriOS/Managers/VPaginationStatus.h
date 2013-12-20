//
//  VPaginationStatus.h
//  victoriOS
//
//  Created by Will Long on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPaginationStatus : NSObject

@property (nonatomic, assign) NSUInteger pagesLoaded;
@property (nonatomic, assign) NSUInteger totalPages;
@property (nonatomic, assign) NSUInteger itemsPerPage;

- (BOOL)isFullyLoaded;

@end
