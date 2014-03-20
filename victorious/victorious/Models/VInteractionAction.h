//
//  VInteractionAction.h
//  victorious
//
//  Created by Will Long on 3/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VInteraction;

@interface VInteractionAction : NSManagedObject

@property (nonatomic, retain) NSNumber * correctGotoNode;
@property (nonatomic, retain) NSNumber * incorrectGotoNode;
@property (nonatomic, retain) NSNumber * timeoutGotoNode;
@property (nonatomic, retain) VInteraction *relationship;

@end
