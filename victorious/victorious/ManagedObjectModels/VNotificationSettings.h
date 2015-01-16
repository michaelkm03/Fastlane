//
//  VNotificationSettings.h
//  victorious
//
//  Created by Patrick Lynch on 11/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface VNotificationSettings : NSManagedObject

@property (nonatomic, retain) NSNumber * isPostFromCreatorEnabled;
@property (nonatomic, retain) NSNumber * isNewFollowerEnabled;
@property (nonatomic, retain) NSNumber * isNewPrivateMessageEnabled;
@property (nonatomic, retain) NSNumber * isNewCommentOnMyPostEnabled;
@property (nonatomic, retain) NSNumber * isPostFromFollowedEnabled;
@property (nonatomic, retain) NSNumber * isPostOnFollowedHashTagEnabled;

@end
