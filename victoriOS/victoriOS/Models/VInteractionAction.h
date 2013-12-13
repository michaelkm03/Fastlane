//
//  VInteractionAction.h
//  victoriOS
//
//  Created by David Keegan on 12/13/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
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
