//
//  VScrollPaginator.h
//  victorious
//
//  Created by Patrick Lynch on 1/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VScrollPaginatorDelegate <NSObject>

@optional

/*
 Called when the user scrolls down far enough that the next page of content
 should start loading and be added into the collectionView or tableView.
 */
- (void)shouldLoadNextPage;

/*
 Called when the user scrolls up far enough that the prevoous page of content
 should start loading and be added into the collectionView or tableView.
 */
- (void)shouldLoadPreviousPage;

@end

@interface VScrollPaginator : NSObject

@property (nonatomic, weak, nullable) IBOutlet id<VScrollPaginatorDelegate> delegate;

/*
 Drives the calculations of when next and previous pages should be loaded,
 which then triggers the calling of the methods in `VScrollPaginatorDelegate`.
 Typically calling code should call this from its own UIScrollViewDelegate method
 implementation of its scrollView.
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@end


NS_ASSUME_NONNULL_END
