//
//  VNotificationSettings.h
//  victorious
//
//  Created by Patrick Lynch on 11/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface VNotificationSettings : NSManagedObject

@property (nonatomic, retain, nullable) NSNumber * isPostFromCreatorEnabled;
@property (nonatomic, retain, nullable) NSNumber * isNewFollowerEnabled;
@property (nonatomic, retain, nullable) NSNumber * isNewPrivateMessageEnabled;
@property (nonatomic, retain, nullable) NSNumber * isNewCommentOnMyPostEnabled;
@property (nonatomic, retain, nullable) NSNumber * isPostFromFollowedEnabled;
@property (nonatomic, retain, nullable) NSNumber * isPostOnFollowedHashTagEnabled;
@property (nonatomic, retain, nullable) NSNumber * isUserTagInCommentEnabled;
@property (nonatomic, retain, nullable) NSNumber * isPeopleLikeMyPostEnabled;

@end

NS_ASSUME_NONNULL_END
