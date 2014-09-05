//
//  VStreamTableDataSource.m
//  victorious
//
//  Created by Josh Hinman on 6/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+ContentCreation.h"
#import "VObjectManager+Pagination.h"
#import "VPaginationManager.h"
#import "VSequenceFilter.h"
#import "VStreamTableDataSource.h"

static char KVOContext;

NSString *const VStreamTableDataSourceDidChangeNotification = @"VStreamTableDataSourceDidChangeNotification";

@interface VStreamTableDataSource ()

@property (nonatomic) BOOL insertingContent;
@property (nonatomic) BOOL isLoading;

@end

@implementation VStreamTableDataSource

- (instancetype)initWithFilter:(VSequenceFilter *)filter
{
    self = [super init];
    if (self)
    {
        self.filter = filter;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentWillBeCreated:) name:VObjectManagerContentWillBeCreatedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentWasCreated:)    name:VObjectManagerContentWasCreatedNotification    object:nil];
    }
    return self;
}

- (void)dealloc
{
    self.filter = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    self.isLoading = YES;
    [[VObjectManager sharedManager] refreshSequenceFilter:self.filter
                                             successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        if (successBlock)
        {
            successBlock();
        }
        self.isLoading = NO;
    }
                                                failBlock:^(NSOperation* operation, NSError* error)
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
    [[VObjectManager sharedManager] loadNextPageOfSequenceFilter:self.filter
                                                    successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        if (successBlock)
        {
            successBlock();
        }
        self.isLoading = NO;
    }
                                                       failBlock:^(NSOperation* operation, NSError* error)
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
    return self.isLoading || [[[VObjectManager sharedManager] paginationManager] isLoadingFilter:self.filter];
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

#pragma mark - NSNotification handlers

- (void)contentWillBeCreated:(NSNotification *)notification
{
    if ([notification.userInfo[VObjectManagerContentFilterIDKey] isEqual:self.filter.objectID])
    {
        self.insertingContent = YES;
        [self.tableView beginUpdates];
    }
}

- (void)contentWasCreated:(NSNotification *)notification
{
    if ([notification.userInfo[VObjectManagerContentFilterIDKey] isEqual:self.filter.objectID])
    {
        NSUInteger index = [notification.userInfo[VObjectManagerContentIndexKey] unsignedIntegerValue];
        
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        self.insertingContent = NO;
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.filter && [keyPath isEqualToString:NSStringFromSelector(@selector(sequences))])
    {
        if (!self.insertingContent)
        {
            [self.tableView reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:VStreamTableDataSourceDidChangeNotification
                                                                object:self];
        }
    }
}

@end
