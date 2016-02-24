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
@property (nonatomic, retain, nullable) NSDate * postedAt;
@property (nonatomic, retain, nullable) NSNumber * remoteId;
@property (nonatomic, retain, nullable) NSString * lastMessageContentType;
@property (nonatomic, retain, nullable) NSOrderedSet *messages;
@property (nonatomic, retain, nullable) VUser *user;
@property (nonatomic, retain) NSNumber * displayOrder;

@end

NS_ASSUME_NONNULL_END
