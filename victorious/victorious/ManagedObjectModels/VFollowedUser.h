//
//  VFollowedUser.h
//  victorious
//
//  Created by Patrick Lynch on 1/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VUser;

NS_ASSUME_NONNULL_BEGIN

@interface VFollowedUser : NSManagedObject

@property (nonatomic, retain) NSNumber *displayOrder;
@property (nonatomic, retain) VUser *objectUser;
@property (nonatomic, retain) VUser *subjectUser;

@end

NS_ASSUME_NONNULL_END

