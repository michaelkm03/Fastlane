//
//  VImageSearchDataSource.h
//  victorious
//
//  Created by Josh Hinman on 4/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VImageSearchDataSource, VImageSearchResult;

@protocol VImageSearchDataDelegate <NSObject>

@required
- (UICollectionViewCell *)dataSource:(VImageSearchDataSource *)dataSource cellForSearchResult:(VImageSearchResult *)searchResult atIndexPath:(NSIndexPath *)indexPath;
- (UICollectionReusableView *)dataSource:(VImageSearchDataSource *)dataSource viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

@end

@interface VImageSearchDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, weak)     id<VImageSearchDataDelegate>  delegate;
@property (nonatomic, weak)     UICollectionView             *collectionView; ///< The UICollectionView object to which the receiver is providing data
@property (nonatomic, readonly) NSString                     *searchTerm;

/**
 Perform a search with the given term. When the search completes, 
 the collection view will be sent a -reloadData message.
 */
- (void)searchWithSearchTerm:(NSString *)searchTerm onCompletion:(void(^)(void))completion onError:(void(^)(NSError *))errorBlock;

/**
 Load the next page of search results
 */
- (void)loadNextPageWithCompletion:(void(^)(void))completion error:(void(^)(NSError *))errorBlock;

/**
 Returns the search result at the given index path.
 */
- (VImageSearchResult *)searchResultAtIndexPath:(NSIndexPath *)indexPath;

/**
 Returns the number of search results
 */
- (NSUInteger)searchResultCount;

@end
