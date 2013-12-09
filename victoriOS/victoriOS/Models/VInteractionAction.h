//
//  VInteractionAction.h
//  victoriOS
//
//  Created by David Keegan on 12/9/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VInteraction;

@interface VInteractionAction : NSManagedObject

@property (nonatomic, retain) NSNumber * correct_goto_node;
@property (nonatomic, retain) NSNumber * incorrect_goto_node;
@property (nonatomic, retain) NSNumber * timeout_goto_node;
@property (nonatomic, retain) VInteraction *relationship;

@end
