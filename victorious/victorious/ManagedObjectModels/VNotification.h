//
//  VNotification.h
//  victorious
//
//  Created by Sharif Ahmed on 4/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VUser;

@interface VNotification : NSManagedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * deepLink;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) VUser *user;

@end
