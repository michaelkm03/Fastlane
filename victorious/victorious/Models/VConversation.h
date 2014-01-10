//
//  VConversation.h
//  victorious
//
//  Created by Will Long on 1/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VMessage, VUser;

@interface VConversation : NSManagedObject

@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSNumber * other_interlocutor_user_id;
@property (nonatomic, retain) VMessage *lastMessage;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSSet *users;
@end

@interface VConversation (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(VMessage *)value;
- (void)removeMessagesObject:(VMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

- (void)addUsersObject:(VUser *)value;
- (void)removeUsersObject:(VUser *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
