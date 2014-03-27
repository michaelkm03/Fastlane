//
//  VConversation.h
//  victorious
//
//  Created by Will Long on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VMessage, VUser;

@interface VConversation : NSManagedObject

@property (nonatomic, retain) NSNumber * other_interlocutor_user_id;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) VMessage *lastMessage;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) VUser *user;
@end

@interface VConversation (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(VMessage *)value;
- (void)removeMessagesObject:(VMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
