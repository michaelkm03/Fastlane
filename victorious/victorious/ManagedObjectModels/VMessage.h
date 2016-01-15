//
//  VMessage.h
//  victorious
//
//  Created by Will Long on 9/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VConversation, VNotification, VUser, VMediaAttachment;

@interface VMessage : NSManagedObject

@property (nonatomic, retain) NSString * mediaUrl;
@property (nonatomic, retain) NSDate * postedAt;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSNumber * senderUserId;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * thumbnailUrl;
@property (nonatomic, retain) NSString * mediaType;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) VConversation *conversation;
@property (nonatomic, retain) VNotification *notification;
@property (nonatomic, retain) VUser *sender;
@property (nonatomic, retain) NSSet *mediaAttachments;
@property (nonatomic, retain) NSNumber * shouldAutoplay;
@property (nonatomic, retain) NSNumber *mediaWidth;
@property (nonatomic, retain) NSNumber *mediaHeight;

@end

@interface VMessage (CoreDataGeneratedAccessors)

- (void)addMediaAttachmentsObject:(VMediaAttachment *)value;
- (void)removeMediaAttachmentsObject:(VMediaAttachment *)value;
- (void)addMediaAttachments:(NSSet *)values;
- (void)removeMediaAttachments:(NSSet *)values;

@end