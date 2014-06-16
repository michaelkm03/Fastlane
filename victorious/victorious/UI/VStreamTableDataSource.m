//
//  VStreamTableDataSource.m
//  victorious
//
//  Created by Josh Hinman on 6/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSIndexSet+Map.h"
#import "VObjectManager+Pagination.h"
#import "VSequenceFilter.h"
#import "VStreamTableDataSource.h"

static char KVOContext;

@implementation VStreamTableDataSource

- (instancetype)initWithFilter:(VSequenceFilter *)filter
{
    self = [super init];
    if (self)
    {
        self.filter = filter;
    }
    return self;
}

- (void)dealloc
{
    self.filter = nil;
}

- (void)setFilter:(VSequenceFilter *)filter
{
    if (filter == _filter)
    {
        return;
    }
    
    if (_filter)
    {
        [_filter removeObserver:self forKeyPath:NSStringFromSelector(@selector(sequences)) context:&KVOContext];
    }
    
    _filter = filter;
    
    if (filter)
    {
        [filter addObserver:self forKeyPath:NSStringFromSelector(@selector(sequences)) options:(NSKeyValueObservingOptionPrior | NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&KVOContext];
    }
}

- (VSequence *)sequenceAtIndexPath:(NSIndexPath *)indexPath
{
    return self.filter.sequences[indexPath.row];
}

- (NSIndexPath *)indexPathForSequence:(VSequence *)sequence
{
    NSUInteger index = [self.filter.sequences indexOfObject:sequence];
    return [NSIndexPath indexPathForItem:(NSInteger)index inSection:0];
}

- (NSUInteger)count
{
    return self.filter.sequences.count;
}

- (void)refreshWithSuccess:(void (^)(void))successBlock failure:(void (^)(NSError *))failureBlock
{
    [[VObjectManager sharedManager] refreshSequenceFilter:self.filter
                                             successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        if (successBlock)
        {
            successBlock();
        }
    }
                                                failBlock:^(NSOperation* operation, NSError* error)
    {
        if (failureBlock)
        {
            failureBlock(error);
        }
    }];
}

- (void)loadNextPageWithSuccess:(void (^)(void))successBlock failure:(void (^)(NSError *))failureBlock
{
    [[VObjectManager sharedManager] loadNextPageOfSequenceFilter:self.filter
                                                    successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        if (successBlock)
        {
            successBlock();
        }
    }
                                                       failBlock:^(NSOperation* operation, NSError* error)
    {
        if (failureBlock)
        {
            failureBlock(error);
        }
    }];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VSequence *sequence = [self sequenceAtIndexPath:indexPath];
    return [self.delegate dataSource:self cellForSequence:sequence atIndexPath:indexPath];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.filter && [keyPath isEqualToString:NSStringFromSelector(@selector(sequences))])
    {
        NSKeyValueChange kind = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
        
        if (change[NSKeyValueChangeNotificationIsPriorKey])
        {
            if (kind == NSKeyValueChangeInsertion || kind == NSKeyValueChangeRemoval)
            {
                [self.tableView beginUpdates];
            }
            return;
        }
        
        NSIndexSet *indexSet = change[NSKeyValueChangeIndexesKey];
        NSArray *indexPaths;
        if (indexSet)
        {
            indexPaths = [indexSet map:^(NSUInteger idx) { return [NSIndexPath indexPathForItem:idx inSection:0]; }];
        }
        
        switch (kind)
        {
            case NSKeyValueChangeInsertion:
                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
                break;
                
            case NSKeyValueChangeRemoval:
                [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
                break;

            case NSKeyValueChangeReplacement:
            default:
                [self.tableView reloadData];
                break;
        }
    }
}

@end
