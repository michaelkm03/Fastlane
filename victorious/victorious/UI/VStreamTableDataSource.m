//
//  VStreamTableDataSource.m
//  victorious
//
//  Created by Josh Hinman on 6/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+Pagination.h"
#import "VSequenceFilter.h"
#import "VStreamTableDataSource.h"

@interface VStreamTableDataSource ()

@end

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
        [self.tableView reloadData];
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
        [self.tableView reloadData];
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

@end
