//
//  VMessageTableDataSource.m
//  victorious
//
//  Created by Josh Hinman on 8/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMessageTableDataSource.h"

#import "VConstants.h"
#import "VMessageCell.h"
#import "VObjectManager+ContentCreation.h"
#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Pagination.h"
#import "VPaginationManager.h"
#import "VUnreadMessageCountCoordinator.h"
#import "VUser.h"
#import "VUser+RestKit.h"
#import "VConversation.h"
#import "VConversation+UnreadMessageCount.h"
#import "VMessage.h"

static NSString * const kGenericErrorDomain = @"VMessageTableDataSourceError";

static const NSInteger kConversationSection    = 0; ///< The table view section that holds the real conversation cells
static const NSInteger kPendingMessagesSection = 1; ///< The table view section that holds pending messages (being sent or waiting to be sent)

static const NSInteger kGenericErrorCode       = 1;

static const int64_t kPollFrequencyInSeconds = 5;
static       char    kKVOContext;

@interface VMessageTableDataSource ()

@property (nonatomic, strong) VConversation  *conversation;
@property (nonatomic)         BOOL            newConversation; ///< YES if this conversation does not yet have a corresponding VConversation object
@property (nonatomic)         BOOL            isLoading;
@property (nonatomic)         BOOL            liveUpdating;
@property (nonatomic)         BOOL            ignoreModelChanges; ///< If YES, model changes detected via KVO will be ignored. Careful with this!
@property (nonatomic, strong) NSMutableArray *pendingMessages; ///< Array of VMessage objects that have been sent to the server but haven't shown up in a refresh yet

@end

@implementation VMessageTableDataSource

- (instancetype)initWithObjectManager:(VObjectManager *)objectManager
{
    NSParameterAssert(objectManager != nil);

    self = [super init];
    if (self)
    {
        _objectManager = objectManager;
        _pendingMessages = [[NSMutableArray alloc] init];
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
        [_conversation removeObserver:self forKeyPath:NSStringFromSelector(@selector(messages)) context:&kKVOContext];
    }
    
    _conversation = conversation;
    
    if (conversation)
    {
        [conversation addObserver:self forKeyPath:NSStringFromSelector(@selector(messages)) options:(NSKeyValueObservingOptionPrior | NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&kKVOContext];
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
    
    if (self.conversation != nil)
    {
        self.isLoading = YES;
        [self.objectManager loadMessagesForConversation:self.conversation
                                                pageType:VPageTypeFirst
                                              successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
        {
            self.isLoading = NO;
            [self.conversation.managedObjectContext saveToPersistentStore:nil];
            [self.messageCountCoordinator markConversationRead:self.conversation];
            
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
    
    if (self.conversation != nil || self.newConversation)
    {
        self.isLoading = YES;
        [self.objectManager loadMessagesForConversation:self.conversation
                                               pageType:VPageTypeNext
                                          successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
        {
            self.isLoading = NO;
            [self.conversation markMessagesAsRead];
            [self.conversation.managedObjectContext saveToPersistentStore:nil];
            
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

- (BOOL)areMorePagesAvailable
{
    return self.conversation &&
        self.conversation.messages.count &&
        self.conversation.currentPageNumber.intValue < self.conversation.maxPageNumber.intValue;
}

- (void)beginLiveUpdates
{
    self.liveUpdating = YES;
    __typeof(self) __weak weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kPollFrequencyInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void)
    {
        id strongSelf = weakSelf;
        if (strongSelf)
        {
            if ([strongSelf liveUpdating])
            {
                [strongSelf goLiveUpdate];
            }
        }
    });
}

- (void)endLiveUpdates
{
    self.liveUpdating = NO;
}

- (void)goLiveUpdate
{
    if (self.conversation != nil && !self.isLoading)
    {
        self.isLoading = YES;
        [self.objectManager loadNewestMessagesInConversation:self.conversation
                                                successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
        {
            self.isLoading = NO;
            self.ignoreModelChanges = YES;
            NSMutableOrderedSet *messages = [self.conversation.messages mutableCopy];
            
            NSIndexPath *indexPathForNewMessage = nil;
            NSMutableIndexSet *indexesOfPendingMessagesToRemove = [[NSMutableIndexSet alloc] init];
            [self.tableView beginUpdates];
            for (VMessage *message in resultObjects)
            {
                indexPathForNewMessage = [NSIndexPath indexPathForRow:messages.count inSection:kConversationSection];
                NSUInteger pendingMessageIndex = [self.pendingMessages indexOfObject:message];
                if (pendingMessageIndex != NSNotFound)
                {
                    [indexesOfPendingMessagesToRemove addIndex:pendingMessageIndex];
                    [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:pendingMessageIndex inSection:kPendingMessagesSection] toIndexPath:indexPathForNewMessage];
                }
                else
                {
                    [self.tableView insertRowsAtIndexPaths:@[indexPathForNewMessage] withRowAnimation:UITableViewRowAnimationTop];
                }
                [messages addObject:message];
            }
            [self.pendingMessages removeObjectsAtIndexes:indexesOfPendingMessagesToRemove];
            
            self.conversation.messages = messages;
            [self.conversation.managedObjectContext saveToPersistentStore:nil];
            self.ignoreModelChanges = NO;
            
            [self.tableView endUpdates];
            
            [self.tableView scrollToRowAtIndexPath:indexPathForNewMessage atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            
            void (^scheduleAnotherPoll)(void) = ^(void)
            {
                if (self.liveUpdating)
                {
                    [self beginLiveUpdates];
                }
            };
            
            if (resultObjects.count > 0)
            {
                // mark these messages as read on the server
                [self.messageCountCoordinator markConversationRead:self.conversation];
                scheduleAnotherPoll();
            }
            else
            {
                scheduleAnotherPoll();
            }
        }
                                                   failBlock:^(NSOperation *operation, NSError *error)
        {
            self.isLoading = NO;
            if ([error.domain isEqualToString:kVictoriousErrorDomain] && error.code == kTooManyNewMessagesErrorCode)
            {
                [self refreshWithCompletion:^(NSError *error)
                {
                    if (self.liveUpdating)
                    {
                        [self beginLiveUpdates]; // schedule another poll
                    }
                }];
            }
            else
            {
                if (self.liveUpdating)
                {
                    [self beginLiveUpdates]; // schedule another poll
                }
            }
        }];
    }
    else if (self.liveUpdating)
    {
        [self beginLiveUpdates]; // schedule another poll
    }
}

- (void)reloadTableView
{
    CGSize beforeSize = self.tableView.contentSize;
    
    if (self.conversation && self.pendingMessages.count)
    {
        NSArray *pendingMessages = [self.pendingMessages copy];
        for (NSInteger n = pendingMessages.count - 1; n >= 0; n--)
        {
            if ([self.conversation.messages containsObject:pendingMessages[n]])
            {
                [self.pendingMessages removeObjectAtIndex:n];
            }
        }
    }
    
    [self.tableView reloadData];
    if (beforeSize.height)
    {
        self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + self.tableView.contentSize.height - beforeSize.height);
    }
}

- (VMessage *)messageAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case kConversationSection:
        {
            if (self.conversation && self.conversation.messages.count > (NSUInteger)indexPath.row)
            {
                return self.conversation.messages[indexPath.row];
            }
            else
            {
                return nil;
            }
        }
            break;
            
        case kPendingMessagesSection:
        {
            if (self.pendingMessages.count > (NSUInteger)indexPath.row)
            {
                return self.pendingMessages[indexPath.row];
            }
            else
            {
                return nil;
            }
        }
            break;
            
        default:
            return nil;
            break;
    }
}

- (void)createMessageWithText:(NSString *)text mediaURL:(NSURL *)mediaURL completion:(void(^)(NSError *))completion
{
    NSAssert([NSThread isMainThread], @"VMessageTableDataSource is intended to be used only on the main thread");
    NSManagedObjectContext *context = self.objectManager.managedObjectStore.mainQueueManagedObjectContext;
    VMessage *message = [self.objectManager messageWithText:text
                                               mediaURLPath:[mediaURL absoluteString]];
    [context saveToPersistentStore:nil];
    
    VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        self.isLoading = NO;
        message.remoteId = @([fullResponse[kVPayloadKey][@"message_id"] integerValue]);
        [message.managedObjectContext saveToPersistentStore:nil];
        [self addNewMessage:message];
        if ([fullResponse isKindOfClass:[NSDictionary class]])
        {
            if (self.conversation != nil)
            {
                self.conversation.lastMessageText = message.text;
                self.conversation.postedAt = message.postedAt;
            }
            else if (self.newConversation)
            {
                if (self.otherUser.conversation)
                {
                    self.conversation = self.otherUser.conversation;
                }
                else
                {
                    NSAssert([NSThread isMainThread], @"Callbacks are supposed to be on the main thread");
                    VConversation *conversation = [NSEntityDescription insertNewObjectForEntityForName:[VConversation entityName] inManagedObjectContext:context];
                    conversation.remoteId = @([fullResponse[kVPayloadKey][@"conversation_id"] integerValue]);
                    conversation.filterAPIPath = [self.objectManager apiPathForConversationWithRemoteID:conversation.remoteId];
                    conversation.user = self.otherUser;
                    conversation.lastMessageText = message.text;
                    conversation.postedAt = message.postedAt;
                    self.conversation = conversation;
                    [context saveToPersistentStore:nil];
                }
                self.newConversation = NO;
            }
        }
        if (completion)
        {
            completion(nil);
        }
    };
    
    self.isLoading = YES;
    [self.objectManager sendMessage:message
                             toUser:self.otherUser
                       successBlock:success
                          failBlock:^(NSOperation *operation, NSError *error)
    {
        self.isLoading = NO;
        VLog(@"Failed in creating message with error: %@", error);
        [context deleteObject:message];
        
        if (completion)
        {
            completion(error ?: [NSError errorWithDomain:kGenericErrorDomain code:kGenericErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Failed to send message" }]);
        }
    }];
}

- (void)addNewMessage:(VMessage *)newMessage
{
    NSParameterAssert(newMessage != nil);
    
    [self.tableView beginUpdates];
    NSUInteger newIndex = self.pendingMessages.count;
    [self.pendingMessages addObject:newMessage];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newIndex inSection:kPendingMessagesSection]] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:newIndex inSection:kPendingMessagesSection] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
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
            return self.pendingMessages.count;
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
        if (!self.ignoreModelChanges)
        {
            [self reloadTableView];
        }
    }
}

@end
