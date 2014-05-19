//
//  VImageSearchDataSource.m
//  victorious
//
//  Created by Josh Hinman on 4/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VImageSearchDataSource.h"
#import "VImageSearchResult.h"
#import "VObjectManager+ImageSearch.h"

@interface VImageSearchDataSource ()

@property (nonatomic, copy) NSArray *results;

@end

@implementation VImageSearchDataSource

- (void)searchWithSearchTerm:(NSString *)searchTerm onCompletion:(void (^)(void))completion onError:(void (^)(NSError *))errorBlock
{
    self.searchTerm = searchTerm;
    [[VObjectManager sharedManager] imageSearchWithKeyword:searchTerm
                                                pageNumber:1
                                              itemsPerPage:35
                                              successBlock:^(NSOperation *operation, id fullResponse, NSArray *responseObjects)
    {
        self.results = responseObjects;
        [self.collectionView reloadData];
        if (completion)
        {
            completion();
        }
    }
                                                 failBlock:^(NSOperation *operation, NSError *error)
    {
        if (errorBlock)
        {
            errorBlock(error);
        }
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (NSInteger)self.results.count;
}

- (VImageSearchResult *)searchResultAtIndexPath:(NSIndexPath *)indexPath
{
    return self.results[indexPath.row];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.delegate dataSource:self cellForSearchResult:[self searchResultAtIndexPath:indexPath] atIndexPath:indexPath];
}

- (void)setSearchTerm:(NSString *)searchTerm
{
    _searchTerm = [searchTerm copy];
}

@end
