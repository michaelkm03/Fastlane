//
//  VMessage.h
//  victorious
//
//  Created by Will Long on 5/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VConversation, VUser;

@interface VMessage : NSManagedObject

@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSDate * postedAt;
@property (nonatomic, retain) NSNumber * senderUserId;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * thumbnailPath;
@property (nonatomic, retain) NSString * mediaPath;
@property (nonatomic, retain) VConversation *conversation;
@property (nonatomic, retain) VConversation *lastMessageInverse;
@property (nonatomic, retain) VUser *user;

@end
