//
//  VStreamCollectionViewDataSource.m
//  victorious
//
//  Created by Will Long on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCollectionViewDataSource.h"

//UI
#import "VDirectoryItemCell.h"

//Managers
#import "VObjectManager+Pagination.h"
#import "VPaginationManager.h"

//Data Models
#import "VStream.h"

static char KVOContext;

NSString *const VStreamCollectionDataSourceDidChangeNotification = @"VStreamCollectionDataSourceDidChangeNotification";

@interface VStreamCollectionViewDataSource()

@property (nonatomic) BOOL isLoading;

@end

@implementation VStreamCollectionViewDataSource

- (void)dealloc
{
    [self removeKVOObservers];
}

- (instancetype)initWithStream:(VStream *)stream
{
    self = [self init];
    if (self)
    {
        self.stream = stream;
    }
    return self;
}

- (void)setStream:(VStream *)stream
{
    if (stream == _stream)
    {
        return;
    }
    
    [self removeKVOObservers];
    
    _stream = stream;
    
    if (stream)
    {
        [stream addObserver:self
                 forKeyPath:NSStringFromSelector(@selector(streamItems))
                    options:(NSKeyValueObservingOptionPrior | NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                    context:&KVOContext];
    }
}

- (void)removeKVOObservers
{
    [_stream removeObserver:self forKeyPath:NSStringFromSelector(@selector(streamItems)) context:&KVOContext];
}

- (VStreamItem *)itemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.count || self.count <= (NSUInteger)indexPath.row)
    {
        return nil;
    }
    
    return [self.stream.streamItems objectAtIndex:indexPath.row];
}

- (NSIndexPath *)indexPathForItem:(VStreamItem *)streamItem
{
    NSInteger section = self.hasHeaderCell ? 1 : 0;
    NSUInteger index = [self.stream.streamItems indexOfObject:streamItem];
    return [NSIndexPath indexPathForItem:(NSInteger)index inSection:section];
}

- (NSUInteger)count
{
    return self.stream.streamItems.count;
}

- (void)refreshWithSuccess:(void (^)(void))successBlock failure:(void (^)(NSError *))failureBlock
{
    self.isLoading = YES;
    [[VObjectManager sharedManager] loadStream:self.stream
                                      pageType:VPageTypeFirst
                                     successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
     {
         if (successBlock)
         {
             successBlock();
         }
         self.isLoading = NO;
     }
                                        failBlock:^(NSOperation *operation, NSError *error)
     {
         if (failureBlock)
         {
             failureBlock(error);
         }
         self.isLoading = NO;
     }];
}

- (void)loadNextPageWithSuccess:(void (^)(void))successBlock failure:(void (^)(NSError *))failureBlock
{
    self.isLoading = YES;
    [[VObjectManager sharedManager] loadStream:self.stream
                                      pageType:VPageTypeNext
                                  successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
     {
         if (successBlock)
         {
             successBlock();
         }
         self.isLoading = NO;
     }
                                               failBlock:^(NSOperation *operation, NSError *error)
     {
         if (failureBlock)
         {
             failureBlock(error);
         }
         self.isLoading = NO;
     }];
}

- (BOOL)isFilterLoading
{
    NSManagedObjectContext *context = [[[VObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext];
    VAbstractFilter *filter = [[VObjectManager sharedManager] filterForStream:self.stream managedObjectContext:context];
    return [[[VObjectManager sharedManager] paginationManager] isLoadingFilter:filter];
}

- (NSInteger)sectionIndexForContent
{
    if ( self.hasHeaderCell )
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.hasHeaderCell && section == 0)
    {
        return 1;
    }
    
    return [self count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.delegate dataSource:self cellForIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (self.hasHeaderCell)
    {
        return 2;
    }
    return 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.stream && [keyPath isEqualToString:NSStringFromSelector(@selector(streamItems))])
    {
        [self.collectionView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:VStreamCollectionDataSourceDidChangeNotification
                                                            object:self];
    }
}

@end
