//
//  VFollowedHashtag.h
//  victorious
//
//  Created by Patrick Lynch on 1/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VHashtag, VUser;

NS_ASSUME_NONNULL_BEGIN

@interface VFollowedHashtag : NSManagedObject

@property (nonatomic, retain) NSNumber *displayOrder;
@property (nonatomic, retain) VHashtag *hashtag;
@property (nonatomic, retain) VUser *user;

@end

NS_ASSUME_NONNULL_END
