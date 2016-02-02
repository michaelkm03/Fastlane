//
//  VConversation.h
//  
//
//  Created by Sharif Ahmed on 6/2/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VMessage, VUser;

NS_ASSUME_NONNULL_BEGIN

@interface VConversation: NSManagedObject

@property (nonatomic, retain, nullable) NSNumber * isRead;
@property (nonatomic, retain, nullable) NSString * lastMessageText;
@property (nonatomic, retain, null_unspecified) NSDate * postedAt;
@property (nonatomic, retain, nullable) NSNumber * remoteId;
@property (nonatomic, retain, nullable) NSString * lastMessageContentType;
@property (nonatomic, retain, nullable) NSOrderedSet *messages;
@property (nonatomic, retain, nullable) VUser *user;
@property (nonatomic, retain, null_unspecified) NSNumber * displayOrder; // This will be nonnull once the rest of the Core Data models are audited

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

NS_ASSUME_NONNULL_END
