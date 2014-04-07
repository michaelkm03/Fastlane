//
//  VImageSearchDataSource.m
//  victorious
//
//  Created by Josh Hinman on 4/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "RKURLEncodedSerialization.h"
#import "VImageSearchDataSource.h"
#import "VImageSearchResult.h"

static NSString * const kCustomSearchEngineID = @"005341061765124966646:aqd697__xec";
static NSString * const kGoogleAPIKey         = @"AIzaSyDwxwgY_fPMJZY4K1IrNRFAtgPajv0YiWk";

@implementation VImageSearchDataSource
{
    NSArray *_results;
}

- (void)searchWithSearchTerm:(NSString *)searchTerm onCompletion:(void (^)(void))completion onError:(void (^)(NSError *))errorBlock
{
    _searchTerm = [searchTerm copy];
    RKObjectRequestOperation *requestOperation = [[RKObjectRequestOperation alloc] initWithRequest:[self searchRequest]
                                                                               responseDescriptors:@[[self responseDescriptor]]];
    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
    {
        _results = [mappingResult.array copy];
        [self.collectionView reloadData];
        if (completion)
        {
            completion();
        }
    }
                                            failure:^(RKObjectRequestOperation *operation, NSError *error)
    {
        if (errorBlock)
        {
            errorBlock(error);
        }
    }];
    [requestOperation start];
}

- (NSURLRequest *)searchRequest
{
    NSDictionary *params = @{@"q": self.searchTerm,
                             @"cx": kCustomSearchEngineID,
                             @"searchType": @"image",
                             @"safe": @"medium",
                             @"key": kGoogleAPIKey,
                             };
    NSString *url = [NSString stringWithFormat:@"https://www.googleapis.com/customsearch/v1?%@", RKURLEncodedStringFromDictionaryWithEncoding(params, NSUTF8StringEncoding)];
    return [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
}

- (RKResponseDescriptor *)responseDescriptor
{
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[VImageSearchResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"title": @"title",
                                                        @"image.thumbnailLink": @"thumbnailURL",
                                                        @"link": @"sourceURL"
                                                        }];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:resultMapping
                                                                                            method:RKRequestMethodAny
                                                                                       pathPattern:nil
                                                                                           keyPath:@"items"
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    return responseDescriptor;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (NSInteger)_results.count;
}

- (VImageSearchResult *)searchResultAtIndexPath:(NSIndexPath *)indexPath
{
    return _results[indexPath.row];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.delegate dataSource:self cellForSearchResult:[self searchResultAtIndexPath:indexPath] atIndexPath:indexPath];
}

@end
