//
//  VMessageTableDataSource.m
//  victorious
//
//  Created by Josh Hinman on 8/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSDate+timeSince.h"
#import "VCommentTextAndMediaView.h"
#import "VConstants.h"
#import "VConversation.h"
#import "VMessage.h"
#import "VMessageCell.h"
#import "VMessageTableDataSource.h"
#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Pagination.h"
#import "VPaginationManager.h"
#import "VUser.h"
#import "VUser+RestKit.h"

static NSString * const kGenericErrorDomain = @"VMessageTableDataSourceError";

static const NSInteger kConversationSection    = 0; ///< The table view section that holds the real conversation cells
static const NSInteger kPendingMessagesSection = 1; ///< The table view section that holds pending messages (being sent or waiting to be sent)

static const NSInteger kGenericErrorCode       = 1;

static char KVOContext;

@interface VMessageTableDataSource ()

@property (nonatomic, strong) VConversation *conversation;
@property (nonatomic)         BOOL           newConversation; //< YES if this conversation does not yet have a corresponding VConversation object
@property (nonatomic)         BOOL           isLoading;

@end

@implementation VMessageTableDataSource

- (instancetype)initWithObjectManager:(VObjectManager *)objectManager
{
    NSParameterAssert(objectManager != nil);

    self = [super init];
    if (self)
    {
        _objectManager = objectManager;
    }
    return self;
}

- (void)dealloc
{
    self.otherUser = nil;
}

- (void)setOtherUser:(VUser *)otherUser
{
    if (_otherUser == otherUser)
    {
        return;
    }
    
    _otherUser = otherUser;
    self.conversation = otherUser.conversation;
    
    [self reloadTableView];
}

- (void)setConversation:(VConversation *)conversation
{
    if (_conversation == conversation)
    {
        return;
    }
    
    if (_conversation)
    {
        [_conversation removeObserver:self forKeyPath:NSStringFromSelector(@selector(messages)) context:&KVOContext];
    }
    
    _conversation = conversation;
    
    if (conversation)
    {
        [conversation addObserver:self forKeyPath:NSStringFromSelector(@selector(messages)) options:(NSKeyValueObservingOptionPrior | NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&KVOContext];
    }
}

- (void)refreshWithCompletion:(void (^)(NSError *))completion
{
    if (self.isLoading)
    {
        if (completion)
        {
            completion([NSError errorWithDomain:kGenericErrorDomain code:kGenericErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Already loading, can't begin again" }]);
        }
    }
    
    if (self.conversation)
    {
        self.isLoading = YES;
        [self.objectManager refreshMessagesForConversation:self.conversation
                                              successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
        {
            self.isLoading = NO;
            if (completion)
            {
                completion(nil);
            }
        }
                                                 failBlock:^(NSOperation *operation, NSError *error)
        {
            self.isLoading = NO;
            if (completion)
            {
                completion(error ?: [NSError errorWithDomain:kGenericErrorDomain code:kGenericErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Could not refresh conversation from server" }]);
            }
        }];
    }
    else if (self.newConversation)
    {
        if (completion)
        {
            completion(nil);
        }
    }
    else
    {
        [self loadConversationWithCompletion:^(NSError *error)
        {
            if (error)
            {
                if (completion)
                {
                    completion(error);
                }
            }
            else if (!self.newConversation)
            {
                [self refreshWithCompletion:completion];
            }
            else if (completion)
            {
                completion(nil);
            }
        }];
    }
}

- (void)loadNextPageWithCompletion:(void (^)(NSError *))completion
{
    if (self.isLoading)
    {
        if (completion)
        {
            completion([NSError errorWithDomain:kGenericErrorDomain code:kGenericErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Already loading, can't begin again" }]);
        }
    }
    
    if (self.conversation || self.newConversation)
    {
        self.isLoading = YES;
        [self.objectManager loadNextPageOfConversation:self.conversation
                                          successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
        {
            self.isLoading = NO;
            if (completion)
            {
                completion(nil);
            }
        }
                                             failBlock:^(NSOperation *operation, NSError *error)
        {
            self.isLoading = NO;
            if (completion)
            {
                completion(error ?: [NSError errorWithDomain:kGenericErrorDomain code:kGenericErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Could not refresh conversation from server" }]);
            }
        }];
    }
    else
    {
        [self loadConversationWithCompletion:^(NSError *error)
        {
            if (error)
            {
                if (completion)
                {
                    completion(error);
                }
            }
            else
            {
                [self refreshWithCompletion:completion];
            }
        }];
    }
}

- (void)loadConversationWithCompletion:(void (^)(NSError *))completion
{
    if (self.isLoading)
    {
        if (completion)
        {
            completion([NSError errorWithDomain:kGenericErrorDomain code:kGenericErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Already loading, can't begin again" }]);
        }
    }
    
    self.isLoading = YES;
    [self.objectManager conversationWithUser:self.otherUser
                                successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
    {
        self.isLoading = NO;
        if (resultObjects.count)
        {
            self.conversation = resultObjects.firstObject;
            if (completion)
            {
                completion(nil);
            }
        }
        else if (completion)
        {
            completion([NSError errorWithDomain:kGenericErrorDomain code:kGenericErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Server didn't report any errors but gave us no conversation object" }]);
        }
    }
                                   failBlock:^(NSOperation *operation, NSError *error)
    {
        self.isLoading = NO;
        if (error.code == kVConversationDoesNotExistError)
        {
            self.newConversation = YES;
            if (completion)
            {
                completion(nil);
            }
        }
        else if (completion)
        {
            completion(error ?: [NSError errorWithDomain:kGenericErrorDomain code:kGenericErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Could not retrieve conversation from server" }]);
        }
    }];
}

- (BOOL)isLoading
{
    return _isLoading || [self.objectManager.paginationManager isLoadingFilter:self.conversation];
}

- (BOOL)areMorePagesAvailable
{
    return self.conversation &&
        self.conversation.messages.count &&
        self.conversation.currentPageNumber.intValue < self.conversation.maxPageNumber.intValue;
}

- (void)beginLiveUpdates
{
    // TODO
}

- (void)endLiveUpdates
{
    // TODO
}


- (void)reloadTableView
{
    CGSize beforeSize = self.tableView.contentSize;
    [self.tableView reloadData];
    if (beforeSize.height)
    {
        self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + self.tableView.contentSize.height - beforeSize.height);
    }
}

- (VMessage *)messageAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kConversationSection)
    {
        if (!self.conversation || self.conversation.messages.count <= indexPath.row)
        {
            return nil;
        }
        else
        {
            return self.conversation.messages[indexPath.row];
        }
    }
    else
    {
        return nil; // TODO
    }
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case kConversationSection:
        {
            if (self.conversation)
            {
                return self.conversation.messages.count;
            }
            else
            {
                return 0;
            }
        }
            break;
        
        case kPendingMessagesSection:
            return 0;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VMessage *message = [self messageAtIndexPath:indexPath];
    return [self.delegate dataSource:self cellForMessage:message atIndexPath:indexPath];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.conversation && [keyPath isEqualToString:NSStringFromSelector(@selector(messages))])
    {
        [self reloadTableView];
    }
}

@end
