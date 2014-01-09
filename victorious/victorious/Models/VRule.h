//
//  VRule.h
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VInteraction;

@interface VRule : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) VInteraction *interaction;

@end
