//
//  VConversation.h
//  victorious
//
//  Created by Will Long on 9/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VAbstractFilter.h"

@class VMessage, VUser;

@interface VConversation : VAbstractFilter

@property (nonatomic, retain) NSString * lastMessageText;
@property (nonatomic, retain) NSNumber * other_interlocutor_user_id;
@property (nonatomic, retain) NSDate * postedAt;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSOrderedSet *messages;
@property (nonatomic, retain) VUser *user;
@end

@interface VConversation (CoreDataGeneratedAccessors)

- (void)insertObject:(VMessage *)value inMessagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMessagesAtIndex:(NSUInteger)idx;
- (void)insertMessages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMessagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMessagesAtIndex:(NSUInteger)idx withObject:(VMessage *)value;
- (void)replaceMessagesAtIndexes:(NSIndexSet *)indexes withMessages:(NSArray *)values;
- (void)addMessagesObject:(VMessage *)value;
- (void)removeMessagesObject:(VMessage *)value;
- (void)addMessages:(NSOrderedSet *)values;
- (void)removeMessages:(NSOrderedSet *)values;
@end
