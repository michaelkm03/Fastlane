//
//  VUnreadConversation.h
//  victorious
//
//  Created by Will Long on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VUser;

@interface VUnreadConversation : NSManagedObject

@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) VUser *user;

@end
