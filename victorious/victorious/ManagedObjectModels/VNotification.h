//
//  VNotification.h
//  victorious
//
//  Created by Sharif Ahmed on 4/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class VUser;

@interface VNotification : NSManagedObject

@property (nonatomic, retain, nullable) NSString * body;
@property (nonatomic, retain, nullable) NSString * deepLink;
@property (nonatomic, retain, nullable) NSString * imageURL;
@property (nonatomic, retain, nullable) NSNumber * isRead;
@property (nonatomic, retain, nullable) NSString * type;
@property (nonatomic, retain, nullable) NSDate * updatedAt;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * remoteId;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) VUser *user;

@end

NS_ASSUME_NONNULL_END
