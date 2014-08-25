//
//  VMessageTableDataSource.m
//  victorious
//
//  Created by Josh Hinman on 8/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSDate+timeSince.h"
#import "VCommentTextAndMediaView.h"
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

@interface VMessageTableDataSource ()

@property (nonatomic, strong) VConversation *conversation;
@property (nonatomic)         BOOL           isLoading;

@end

@implementation VMessageTableDataSource

- (instancetype)initWithUser:(VUser *)otherUser objectManager:(VObjectManager *)objectManager
{
    NSParameterAssert(otherUser != nil);
    NSParameterAssert(objectManager != nil);

    self = [super init];
    if (self)
    {
        _objectManager = objectManager;
        _otherUser = otherUser;
    }
    return self;
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
            [self.tableView reloadData];
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

- (void)loadNextPageWithCompletion:(void (^)(NSError *))completion
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
        [self.objectManager loadNextPageOfConversation:self.conversation
                                          successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
        {
            self.isLoading = NO;
            [self.tableView reloadData];
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
        if (completion)
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

@end
