//
//  VMessage.h
//  victorious
//
//  Created by Will Long on 9/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class VConversation, VNotification, VUser, VMediaAttachment;

@interface VMessage : NSManagedObject

@property (nonatomic, retain, nullable) NSString * mediaUrl;
@property (nonatomic, retain) NSDate * postedAt;
@property (nonatomic, retain, nullable) NSNumber * remoteId;
@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain, nullable) NSString * text;
@property (nonatomic, retain, nullable) NSString * thumbnailUrl;
@property (nonatomic, retain) NSString * mediaType;
@property (nonatomic, retain, nullable) NSNumber * isRead;
@property (nonatomic, retain) VConversation *conversation;
@property (nonatomic, retain, nullable) VNotification *notification;
@property (nonatomic, retain) VUser *sender;
@property (nonatomic, retain) NSSet *mediaAttachments;
@property (nonatomic, retain, nullable) NSNumber * shouldAutoplay;
@property (nonatomic, retain, nullable) NSNumber *mediaWidth;
@property (nonatomic, retain, nullable) NSNumber *mediaHeight;

@end

NS_ASSUME_NONNULL_END
