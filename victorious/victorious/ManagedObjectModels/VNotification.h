//
//  VNotification.h
//  victorious
//
//  Created by Lawrence Leach on 8/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VComment, VMessage, VUser;

@interface VNotification : NSManagedObject

@property (nonatomic, retain) NSString * notifyType;
@property (nonatomic, retain) NSDate * postedAt;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) VUser *user;
@property (nonatomic, retain) VMessage *message;
@property (nonatomic, retain) VComment *comment;
@property (nonatomic, retain) NSString * deeplink;

@end
