//
//  VUser.h
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VComment, VConversation, VStatSequence;

@interface VUser : NSManagedObject

@property (nonatomic, retain) NSString * accessLevel;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSDate * tokenUpdatedAt;
@property (nonatomic, retain) NSString * pictureUrl;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *statSequences;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSSet *conversations;
@end

@interface VUser (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(VComment *)value;
- (void)removeCommentsObject:(VComment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addStatSequencesObject:(VStatSequence *)value;
- (void)removeStatSequencesObject:(VStatSequence *)value;
- (void)addStatSequences:(NSSet *)values;
- (void)removeStatSequences:(NSSet *)values;

- (void)addMessagesObject:(NSManagedObject *)value;
- (void)removeMessagesObject:(NSManagedObject *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

- (void)addConversationsObject:(VConversation *)value;
- (void)removeConversationsObject:(VConversation *)value;
- (void)addConversations:(NSSet *)values;
- (void)removeConversations:(NSSet *)values;

@end
