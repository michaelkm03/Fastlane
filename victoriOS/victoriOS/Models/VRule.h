//
//  VRule.h
//  victoriOS
//
//  Created by David Keegan on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VInteraction;

@interface VRule : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) VInteraction *interaction;

@end
