//
//  VScrollPaginator.h
//  victorious
//
//  Created by Patrick Lynch on 1/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VAbstractFilter+RestKit.h"

@protocol VScrollPaginatorDelegate <NSObject>

@optional
- (void)shouldLoadNextPage;
- (void)shouldLoadPreviousPage;

@end

@interface VScrollPaginator : NSObject

- (instancetype)initWithDelegate:(id<VScrollPaginatorDelegate>)delegate NS_DESIGNATED_INITIALIZER;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@property (nonatomic, weak) id<VScrollPaginatorDelegate> delegate;

@end
