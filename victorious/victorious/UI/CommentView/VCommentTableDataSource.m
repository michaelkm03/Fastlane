//
//  VCommentTableDataSource.m
//  victorious
//
//  Created by Will Long on 8/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCommentTableDataSource.h"

#import "VCommentFilter.h"
#import "VComment.h"

#import "VObjectManager+ContentCreation.h"
#import "VObjectManager+Pagination.h"

static char KVOContext;

@interface VCommentTableDataSource ()

@property (nonatomic) BOOL insertingContent;

@end

@implementation VCommentTableDataSource

- (instancetype)initWithFilter:(VCommentFilter *)filter
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
}

- (void)setFilter:(VCommentFilter *)filter
{
    if (filter == _filter)
    {
        return;
    }
    
    if (_filter)
    {
        [_filter removeObserver:self forKeyPath:NSStringFromSelector(@selector(comments)) context:&KVOContext];
    }
    
    _filter = filter;
    
    if (filter)
    {
        [filter addObserver:self forKeyPath:NSStringFromSelector(@selector(comments)) options:(NSKeyValueObservingOptionPrior | NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&KVOContext];
    }
}

- (VComment *)commentAtIndexPath:(NSIndexPath *)indexPath
{
    return self.filter.comments[indexPath.row];
}

- (NSIndexPath *)indexPathForComment:(VComment*)comment
{
    NSUInteger index = [self.filter.comments indexOfObject:comment];
    return [NSIndexPath indexPathForItem:(NSInteger)index inSection:0];
}

- (NSUInteger)count
{
    return self.filter.comments.count;
}

- (void)refreshWithSuccess:(void (^)(void))successBlock failure:(void (^)(NSError *))failureBlock
{
    [[VObjectManager sharedManager] refreshCommentFilter:self.filter
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
    [[VObjectManager sharedManager] loadNextPageOfCommentFilter:self.filter
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
    VComment *comment = [self commentAtIndexPath:indexPath];
    return [self.delegate dataSource:self cellForComment:comment atIndexPath:indexPath];
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
    if (object == self.filter && [keyPath isEqualToString:NSStringFromSelector(@selector(comments))])
    {
        if (!self.insertingContent)
        {
            [self.tableView reloadData];
        }
    }
}

@end
