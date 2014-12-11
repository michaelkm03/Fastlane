//
//  VUserHashtag.h
//  victorious
//
//  Created by Lawrence Leach on 12/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VUser;

@interface VUserHashtag : NSManagedObject

@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) VUser *user;

@end
