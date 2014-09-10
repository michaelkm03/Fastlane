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
#import "VStreamTableDataSource.h"

#import "VStream.h"

static char KVOContext;

NSString *const VStreamTableDataSourceDidChangeNotification = @"VStreamTableDataSourceDidChangeNotification";

@interface VStreamTableDataSource ()

@property (nonatomic) BOOL insertingContent;
@property (nonatomic) BOOL isLoading;

@property (nonatomic, strong) VAbstractFilter* filter;

@end

@implementation VStreamTableDataSource

- (instancetype)initWithStream:(VStream*)stream
{
    self = [super init];
    if (self)
    {
        self.stream = stream;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentWillBeCreated:) name:VObjectManagerContentWillBeCreatedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentWasCreated:)    name:VObjectManagerContentWasCreatedNotification    object:nil];
    }
    return self;
}

- (void)dealloc
{
    self.stream = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setStream:(VStream *)stream
{
    if (stream == _stream)
    {
        return;
    }
    
    if (_stream)
    {
        [_stream removeObserver:self forKeyPath:NSStringFromSelector(@selector(sequences)) context:&KVOContext];
    }
    
    _stream = stream;
    self.filter = [[VObjectManager sharedManager] filterForStream:stream];
    
    if (stream)
    {
        [stream addObserver:self forKeyPath:NSStringFromSelector(@selector(sequences)) options:(NSKeyValueObservingOptionPrior | NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&KVOContext];
    }
}

- (VSequence *)sequenceAtIndexPath:(NSIndexPath *)indexPath
{
    return self.stream.sequences[indexPath.row];
}

- (NSIndexPath *)indexPathForSequence:(VSequence *)sequence
{
    NSUInteger index = [self.stream.sequences indexOfObject:sequence];
    return [NSIndexPath indexPathForItem:(NSInteger)index inSection:0];
}

- (NSUInteger)count
{
    return self.stream.sequences.count;
}

- (void)refreshWithSuccess:(void (^)(void))successBlock failure:(void (^)(NSError *))failureBlock
{
    self.isLoading = YES;
    [[VObjectManager sharedManager] refreshStream:self.stream
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
    [[VObjectManager sharedManager] loadNextPageOfStream:self.stream
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
    if ([notification.userInfo[VObjectManagerContentFilterIDKey] isEqual:self.stream.objectID])
    {
        self.insertingContent = YES;
        [self.tableView beginUpdates];
    }
}

- (void)contentWasCreated:(NSNotification *)notification
{
    if ([notification.userInfo[VObjectManagerContentFilterIDKey] isEqual:self.stream.objectID])
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
    if (object == self.stream && [keyPath isEqualToString:NSStringFromSelector(@selector(sequences))])
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
